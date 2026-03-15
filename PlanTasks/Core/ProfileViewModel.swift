import Foundation
import Combine
import Factory

@MainActor
final class ProfileViewModel: ObservableObject {
    @Injected(\.authStore) private var authStore

    @Published private(set) var user: AppUser?

    init() {
        authStore.currentUserPublisher
            .assign(to: &$user)
    }

    var avatarInitials: String {
        guard let name = user?.displayName, !name.isEmpty else {
            return user?.email.prefix(2).uppercased() ?? "?"
        }
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    func signOut() {
        try? authStore.signOut()
    }
}
