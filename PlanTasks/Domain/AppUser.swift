import Foundation

struct AppUser: Codable, Identifiable {
    let id: String
    let email: String
    var displayName: String?
}
