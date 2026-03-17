import Foundation
import Combine
import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

// MARK: - reCAPTCHA UI delegate (fallback when APNs unavailable)

private final class PhoneAuthUIDelegate: NSObject, AuthUIDelegate {
    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        topViewController()?.present(viewControllerToPresent, animated: animated, completion: completion)
    }

    func dismiss(animated: Bool, completion: (() -> Void)?) {
        topViewController()?.dismiss(animated: animated, completion: completion)
    }

    private func topViewController() -> UIViewController? {
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController else { return nil }
        var top = rootVC
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}

// MARK: - FirebaseAuthStore

@MainActor
final class FirebaseAuthStore: AuthStoreProtocol {

    @Published private(set) var currentUser: AppUser?

    var currentUserPublisher: AnyPublisher<AppUser?, Never> {
        $currentUser.eraseToAnyPublisher()
    }

    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private let phoneUIDelegate = PhoneAuthUIDelegate()

    init() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor [weak self] in
                self?.currentUser = firebaseUser.map {
                    AppUser(id: $0.uid, email: $0.email ?? "", displayName: $0.displayName)
                }
            }
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signIn(email: String, password: String) async throws -> AppUser {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return AppUser(id: result.user.uid, email: result.user.email ?? "", displayName: result.user.displayName)
    }

    func signUp(email: String, password: String, displayName: String) async throws -> AppUser {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()
        return AppUser(id: result.user.uid, email: result.user.email ?? "", displayName: displayName)
    }

    func signInWithGoogle() async throws -> AppUser {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AppError.unknown
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootVC = windowScene.windows.first?.rootViewController
        else {
            throw AppError.unknown
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)

        guard let idToken = result.user.idToken?.tokenString else {
            throw AppError.unknown
        }
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        let authResult = try await Auth.auth().signIn(with: credential)
        return AppUser(
            id: authResult.user.uid,
            email: authResult.user.email ?? "",
            displayName: authResult.user.displayName
        )
    }

    func sendPhoneVerification(phoneNumber: String) async throws -> String {
        do {
            let id = try await PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: phoneUIDelegate)
            print("✅ Phone verification sent, ID: \(id)")
            return id
        } catch {
            print("❌ Phone verification error: \(error)")
            print("❌ Error details: \((error as NSError).userInfo)")
            throw error
        }
    }

    func signInWithPhone(verificationID: String, code: String) async throws -> AppUser {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code
        )
        let authResult = try await Auth.auth().signIn(with: credential)
        return AppUser(
            id: authResult.user.uid,
            email: authResult.user.email ?? "",
            displayName: authResult.user.displayName
        )
    }

    func signInWithApple(idToken: String, rawNonce: String, fullName: PersonNameComponents?) async throws -> AppUser {
        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: rawNonce,
            fullName: fullName
        )
        let authResult = try await Auth.auth().signIn(with: credential)
        return AppUser(
            id: authResult.user.uid,
            email: authResult.user.email ?? "",
            displayName: authResult.user.displayName
        )
    }

    func signOut() throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }
}
