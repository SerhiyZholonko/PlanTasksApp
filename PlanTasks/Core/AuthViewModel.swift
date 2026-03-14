import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject, ErrorDisplayable {

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
            // TODO: integrate with your auth backend (Firebase, Supabase, custom API, etc.)
            // On success, update AppStartingViewModel.appState to .home
            throw AppError.unknown
        }
    }
}
