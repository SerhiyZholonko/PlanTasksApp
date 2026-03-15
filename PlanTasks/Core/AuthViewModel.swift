import Foundation
import Combine
import Factory

@MainActor
final class AuthViewModel: ObservableObject, ErrorDisplayable {

    @Injected(\.authStore) private var authStore

    @Published var authType: AuthType = .signIn
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var displayName: String = ""
    @Published var isLoading: Bool = false
    @Published var error: Error?

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
}
