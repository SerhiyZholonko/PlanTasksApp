import Foundation

struct AppAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String?
    var actionTitle: String?
    var action: (() -> Void)?

    init(title: String, message: String? = nil, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
}
