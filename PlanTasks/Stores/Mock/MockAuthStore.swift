import Foundation
import Combine

@MainActor
final class MockAuthStore: AuthStoreProtocol {

    @Published private(set) var currentUser: AppUser?

    var currentUserPublisher: AnyPublisher<AppUser?, Never> {
        $currentUser.eraseToAnyPublisher()
    }

    func signIn(email: String, password: String) async throws -> AppUser {
        let user = AppUser(id: UUID().uuidString, email: email, displayName: nil)
        currentUser = user
        return user
    }

    func signUp(email: String, password: String, displayName: String) async throws -> AppUser {
        let user = AppUser(id: UUID().uuidString, email: email, displayName: displayName)
        currentUser = user
        return user
    }

    func signInWithGoogle() async throws -> AppUser {
        let user = AppUser(id: UUID().uuidString, email: "google@mock.com", displayName: "Google User")
        currentUser = user
        return user
    }

    func signOut() throws {
        currentUser = nil
    }
}
