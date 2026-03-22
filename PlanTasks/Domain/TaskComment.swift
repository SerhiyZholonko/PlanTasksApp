import Foundation

struct TaskComment: Identifiable, Codable {
    let id: String
    let authorId: String
    let authorName: String
    let text: String
    let createdAt: Date
}

extension TaskComment {
    static let mock: [TaskComment] = [
        TaskComment(id: UUID().uuidString, authorId: "1", authorName: "Іван Петренко",
                    text: "Починаю роботу над цим завданням", createdAt: Date().addingTimeInterval(-3600)),
        TaskComment(id: UUID().uuidString, authorId: "2", authorName: "Марія Коваленко",
                    text: "Потрібна допомога з документацією", createdAt: Date().addingTimeInterval(-1800)),
    ]
}
