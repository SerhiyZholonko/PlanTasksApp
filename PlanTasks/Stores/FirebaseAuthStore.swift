import Foundation
import Combine
import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

// MARK: - reCAPTCHA UI delegate

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
        while let presented = top.presentedViewController { top = presented }
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
    private let db = Firestore.firestore()

    init() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let firebaseUser {
                    let profile = try? await self.loadProfile(uid: firebaseUser.uid)
                    self.currentUser = AppUser(
                        id: firebaseUser.uid,
                        email: firebaseUser.email ?? "",
                        displayName: firebaseUser.displayName,
                        phoneNumber: firebaseUser.phoneNumber,
                        role: profile?.role ?? .manager,
                        consentGiven: profile?.consentGiven ?? false
                    )
                } else {
                    self.currentUser = nil
                }
            }
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Sign-in methods

    func signInWithGoogle() async throws -> AppUser {
        guard let clientID = FirebaseApp.app()?.options.clientID else { throw AppError.unknown }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { throw AppError.unknown }
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
        guard let idToken = result.user.idToken?.tokenString else { throw AppError.unknown }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result.user.accessToken.tokenString)
        let authResult = try await Auth.auth().signIn(with: credential)
        try await saveRegisteredUser(authResult.user)
        let profile = try? await loadProfile(uid: authResult.user.uid)
        return AppUser(id: authResult.user.uid, email: authResult.user.email ?? "",
                       displayName: authResult.user.displayName,
                       role: profile?.role ?? .manager, consentGiven: profile?.consentGiven ?? false)
    }

    func sendPhoneVerification(phoneNumber: String) async throws -> String {
        try await PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: phoneUIDelegate)
    }

    func signInWithPhone(verificationID: String, code: String) async throws -> AppUser {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)
        let authResult = try await Auth.auth().signIn(with: credential)
        try await saveRegisteredUser(authResult.user)
        let profile = try? await loadProfile(uid: authResult.user.uid)
        return AppUser(id: authResult.user.uid, email: authResult.user.email ?? "",
                       displayName: authResult.user.displayName, phoneNumber: authResult.user.phoneNumber,
                       role: profile?.role ?? .manager, consentGiven: profile?.consentGiven ?? false)
    }

    func signInWithApple(idToken: String, rawNonce: String, fullName: PersonNameComponents?) async throws -> AppUser {
        let credential = OAuthProvider.appleCredential(withIDToken: idToken, rawNonce: rawNonce, fullName: fullName)
        let authResult = try await Auth.auth().signIn(with: credential)
        try await saveRegisteredUser(authResult.user)
        let profile = try? await loadProfile(uid: authResult.user.uid)
        return AppUser(id: authResult.user.uid, email: authResult.user.email ?? "",
                       displayName: authResult.user.displayName,
                       role: profile?.role ?? .manager, consentGiven: profile?.consentGiven ?? false)
    }

    // MARK: - Profile updates

    func updateDisplayName(_ name: String) async throws {
        guard let user = Auth.auth().currentUser else { throw AppError.unknown }
        let request = user.createProfileChangeRequest()
        request.displayName = name
        try await request.commitChanges()
        currentUser?.displayName = name
        try await saveRegisteredUser(user, displayName: name)
    }

    func updateRole(_ role: UserRole) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { throw AppError.unknown }
        try await db.collection("registeredUsers").document(uid).setData(["role": role.rawValue], merge: true)
        currentUser?.role = role
    }

    func grantConsent() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { throw AppError.unknown }
        try await db.collection("registeredUsers").document(uid).setData(["consentGiven": true], merge: true)
        // Also update in all managers' employee lists
        currentUser?.consentGiven = true
    }

    func signOut() throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }

    // MARK: - Firestore helpers

    private func loadProfile(uid: String) async throws -> (role: UserRole, consentGiven: Bool) {
        let doc = try await db.collection("registeredUsers").document(uid).getDocument()
        let data = doc.data() ?? [:]
        let role = UserRole(rawValue: data["role"] as? String ?? "") ?? .manager
        let consent = data["consentGiven"] as? Bool ?? false
        return (role, consent)
    }

    private func saveRegisteredUser(_ firebaseUser: FirebaseAuth.User, displayName: String? = nil) async throws {
        let name = displayName ?? firebaseUser.displayName ?? firebaseUser.email ?? firebaseUser.phoneNumber ?? "Користувач"
        let initials = makeInitials(from: name)
        let data: [String: Any] = [
            "id": firebaseUser.uid,
            "name": name,
            "email": firebaseUser.email ?? "",
            "phoneNumber": firebaseUser.phoneNumber ?? "",
            "avatarInitials": initials
        ]
        try await db.collection("registeredUsers").document(firebaseUser.uid).setData(data, merge: true)
    }

    private func makeInitials(from name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 { return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased() }
        return String(name.prefix(2)).uppercased()
    }
}
