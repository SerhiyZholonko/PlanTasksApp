import Foundation
import Combine

@MainActor
protocol AuthStoreProtocol: AnyObject {
    var currentUser: AppUser? { get }
    var currentUserPublisher: AnyPublisher<AppUser?, Never> { get }

    func signInWithGoogle() async throws -> AppUser
    func signInWithApple(idToken: String, rawNonce: String, fullName: PersonNameComponents?) async throws -> AppUser
    func sendPhoneVerification(phoneNumber: String) async throws -> String
    func signInWithPhone(verificationID: String, code: String) async throws -> AppUser
    func updateDisplayName(_ name: String) async throws
    func signOut() throws
}
