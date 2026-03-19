import Foundation
import Combine
import Factory

@MainActor
final class ProfileViewModel: ObservableObject, ErrorDisplayable {
    @Injected(\.authStore) private var authStore

    @Published private(set) var user: AppUser?
    @Published var editingName: String = ""
    @Published var showNameSheet: Bool = false
    @Published var error: Error?

    init() {
        authStore.currentUserPublisher
            .assign(to: &$user)
    }

    var userIdentifier: String {
        if let email = user?.email, !email.isEmpty { return email }
        if let phone = user?.phoneNumber, !phone.isEmpty { return phone }
        return ""
    }

    var avatarInitials: String {
        if let name = user?.displayName, !name.isEmpty {
            let parts = name.split(separator: " ")
            if parts.count >= 2 { return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased() }
            return String(name.prefix(2)).uppercased()
        }
        if let email = user?.email, !email.isEmpty { return email.prefix(2).uppercased() }
        if let phone = user?.phoneNumber, !phone.isEmpty { return String(phone.suffix(2)) }
        return "?"
    }

    func openNameSheet() {
        editingName = user?.displayName ?? ""
        showNameSheet = true
    }

    func saveName() {
        let name = editingName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        Task(handlingError: self) {
            try await self.authStore.updateDisplayName(name)
            self.showNameSheet = false
        }
    }

    func updateRole(_ role: UserRole) {
        Task(handlingError: self) {
            try await self.authStore.updateRole(role)
        }
    }

    func signOut() {
        try? authStore.signOut()
    }
}
