import Foundation
import Combine
import CryptoKit
import AuthenticationServices
import Factory

enum PhoneAuthStep: Equatable {
    case enterPhone
    case enterCode(verificationID: String)
}

@MainActor
final class AuthViewModel: ObservableObject, ErrorDisplayable {

    @Injected(\.authStore) private var authStore

    @Published var authType: AuthType = .signIn
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var displayName: String = ""
    @Published var isLoading: Bool = false
    @Published var error: Error?

    // MARK: - Phone Auth
    @Published var showPhoneSheet: Bool = false
    @Published var phoneStep: PhoneAuthStep = .enterPhone
    @Published var phoneNumber: String = ""
    @Published var verificationCode: String = ""

    var isEnteringCode: Bool {
        if case .enterCode = phoneStep { return true }
        return false
    }

    private var currentNonce: String?

    var isFormValid: Bool {
        email.isValidEmail && password.count >= 6
    }

    func toggleAuthType() {
        authType = authType == .signIn ? .signUp : .signIn
        error = nil
    }

    func submit() {
        Task(handlingError: self) {
            self.isLoading = true
            defer { self.isLoading = false }
            switch self.authType {
            case .signIn:
                _ = try await self.authStore.signIn(email: self.email, password: self.password)
            case .signUp:
                _ = try await self.authStore.signUp(email: self.email, password: self.password, displayName: self.displayName)
            }
        }
    }

    func signInWithGoogle() {
        Task(handlingError: self) {
            self.isLoading = true
            defer { self.isLoading = false }
            _ = try await self.authStore.signInWithGoogle()
        }
    }

    // MARK: - Apple Sign-In

    func handleAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let nonce = currentNonce,
                let tokenData = credential.identityToken,
                let idToken = String(data: tokenData, encoding: .utf8)
            else {
                error = AppError.unknown
                return
            }
            Task(handlingError: self) {
                self.isLoading = true
                defer { self.isLoading = false }
                _ = try await self.authStore.signInWithApple(
                    idToken: idToken,
                    rawNonce: nonce,
                    fullName: credential.fullName
                )
            }
        case .failure(let err):
            error = err
        }
    }

    // MARK: - Phone Sign-In

    func startPhoneAuth() {
        phoneNumber = ""
        verificationCode = ""
        phoneStep = .enterPhone
        showPhoneSheet = true
    }

    func sendPhoneCode() {
        Task(handlingError: self) {
            self.isLoading = true
            defer { self.isLoading = false }
            let verificationID = try await self.authStore.sendPhoneVerification(phoneNumber: self.phoneNumber)
            self.phoneStep = .enterCode(verificationID: verificationID)
        }
    }

    func verifyPhoneCode() {
        guard case .enterCode(let verificationID) = phoneStep else { return }
        Task(handlingError: self) {
            self.isLoading = true
            defer { self.isLoading = false }
            _ = try await self.authStore.signInWithPhone(verificationID: verificationID, code: self.verificationCode)
        }
    }

    // MARK: - Nonce helpers

    private func randomNonceString(length: Int = 32) -> String {
        var randomBytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let data = SHA256.hash(data: Data(input.utf8))
        return data.map { String(format: "%02x", $0) }.joined()
    }
}
