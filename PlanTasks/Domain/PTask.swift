import Foundation

struct PTask: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var deadline: Date
    var isCompleted: Bool
    var employees: [User]
}

extension PTask {
    static let mockProducts: [PTask] = [
        PTask(id: UUID().uuidString, title: "Оновити документацію", deadline: Date().addingTimeInterval(60*60*24*3), isCompleted: false, employees: [User.mockUsers[0], User.mockUsers[1]]),
        PTask(id: UUID().uuidString, title: "Провести код-рев'ю", deadline: Date().addingTimeInterval(60*60*24*7), isCompleted: false, employees: [User.mockUsers[1]]),
        PTask(id: UUID().uuidString, title: "Налаштувати CI/CD", deadline: Date().addingTimeInterval(60*60*24*10), isCompleted: true, employees: [User.mockUsers[2], User.mockUsers[3]]),
        PTask(id: UUID().uuidString, title: "Підготувати презентацію", deadline: Date().addingTimeInterval(60*60*24*14), isCompleted: false, employees: [User.mockUsers[4]]),
        PTask(id: UUID().uuidString, title: "Тестування API", deadline: Date().addingTimeInterval(60*60*24*2), isCompleted: false, employees: User.mockUsers),
    ]
}
