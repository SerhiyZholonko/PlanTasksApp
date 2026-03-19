import Foundation

struct AppUser: Codable, Identifiable {
    let id: String
    let email: String
    var displayName: String?
    var phoneNumber: String?
    var role: UserRole
    var consentGiven: Bool

    init(id: String, email: String, displayName: String? = nil, phoneNumber: String? = nil,
         role: UserRole = .manager, consentGiven: Bool = false) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.phoneNumber = phoneNumber
        self.role = role
        self.consentGiven = consentGiven
    }
}
