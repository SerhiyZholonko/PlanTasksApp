import Foundation
import Combine

@MainActor
final class MockAuthStore: AuthStoreProtocol {

    @Published private(set) var currentUser: AppUser?

    var currentUserPublisher: AnyPublisher<AppUser?, Never> {
        $currentUser.eraseToAnyPublisher()
    }

    func signInWithGoogle() async throws -> AppUser {
        let user = AppUser(id: UUID().uuidString, email: "google@mock.com", displayName: "Google User")
        currentUser = user
        return user
    }

    func sendPhoneVerification(phoneNumber: String) async throws -> String {
        return "mock-verification-id"
    }

    func signInWithPhone(verificationID: String, code: String) async throws -> AppUser {
        let user = AppUser(id: UUID().uuidString, email: "", displayName: "Phone User")
        currentUser = user
        return user
    }

    func signInWithApple(idToken: String, rawNonce: String, fullName: PersonNameComponents?) async throws -> AppUser {
        let name = [fullName?.givenName, fullName?.familyName].compactMap { $0 }.joined(separator: " ")
        let user = AppUser(id: UUID().uuidString, email: "apple@mock.com", displayName: name.isEmpty ? "Apple User" : name)
        currentUser = user
        return user
    }

    func updateDisplayName(_ name: String) async throws {
        guard let user = currentUser else { return }
        currentUser = AppUser(id: user.id, email: user.email, displayName: name, phoneNumber: user.phoneNumber)
    }

    func signOut() throws {
        currentUser = nil
    }
}
