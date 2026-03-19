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

    func sendPhoneVerification(phoneNumber: String) async throws -> String { "mock-id" }

    func signInWithPhone(verificationID: String, code: String) async throws -> AppUser {
        let user = AppUser(id: UUID().uuidString, email: "", displayName: nil, phoneNumber: "+380991234567")
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
        currentUser?.displayName = name
    }

    func updateRole(_ role: UserRole) async throws {
        currentUser?.role = role
    }

    func grantConsent() async throws {
        currentUser?.consentGiven = true
    }

    func signOut() throws {
        currentUser = nil
    }
}
