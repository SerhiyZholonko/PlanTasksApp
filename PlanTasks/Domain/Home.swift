import Foundation

struct Home: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var title: String
    var description: String?
    var isCompleted: Bool
    let dateCreated: Date

    init(
        id: String = UUID().uuidString,
        title: String = "",
        description: String? = nil,
        isCompleted: Bool = false,
        dateCreated: Date = .now
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.dateCreated = dateCreated
    }
}

extension Home {
    static var mock: Home { Home(title: "Sample") }
    static var mocks: [Home] {
        [
            Home(title: "First item"),
            Home(title: "Second item", description: "With description"),
            Home(title: "Third item", isCompleted: true)
        ]
    }
}
