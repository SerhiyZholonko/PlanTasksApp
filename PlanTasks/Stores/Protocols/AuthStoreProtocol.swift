import Foundation
import Combine

@MainActor
protocol AuthStoreProtocol: AnyObject {
    var currentUser: AppUser? { get }
    var currentUserPublisher: AnyPublisher<AppUser?, Never> { get }

    func signIn(email: String, password: String) async throws -> AppUser
    func signUp(email: String, password: String, displayName: String) async throws -> AppUser
    func signInWithGoogle() async throws -> AppUser
    func signOut() throws
}
