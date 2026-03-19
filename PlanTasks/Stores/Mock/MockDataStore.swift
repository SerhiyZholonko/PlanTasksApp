import Foundation

@MainActor
final class MockDataStore: DataStoreProtocol {

    // Глобальний реєстр усіх зареєстрованих користувачів (імітує Firestore users/)
    private let allRegisteredUsers: [User] = User.mockUsers + [
        User(id: UUID(), name: "Андрій Мороз", email: "andriy@mail.com", avatarInitials: "АМ"),
        User(id: UUID(), name: "Оксана Гриценко", email: "oksana@mail.com", avatarInitials: "ОГ"),
        User(id: UUID(), name: "Тарас Кравченко", email: "taras@mail.com", avatarInitials: "ТК"),
        User(id: UUID(), name: "Юлія Савченко", email: "yulia@mail.com", avatarInitials: "ЮС"),
        User(id: UUID(), name: "Богдан Руденко", email: "bohdan@mail.com", avatarInitials: "БР"),
    ]

    var mockUsers: [User] = User.mockUsers
    var mockTasks: [PTask] = PTask.mockProducts
    
    func getAllTasks() async throws -> [PTask] { mockTasks }
    
    func addTask(_ task: PTask) async throws {
        mockTasks.append(task)
    }
    
    func updateTask(_ task: PTask) async throws {
        if let i = mockTasks.firstIndex(where: { $0.id == task.id }) {
            mockTasks[i] = task
        }
    }
    
    func deleteTask(_ task: PTask) async throws {
        mockTasks.removeAll { $0.id == task.id }
    }
    
    func getAllUsers() async throws -> [User] { mockUsers }
    func addUser(_ item: User) async throws { mockUsers.append(item) }
    func updateUser(_ item: User) async throws {
        if let i = mockUsers.firstIndex(where: { element in element.id == item.id }) {
            mockUsers[i] = item
        }
    }
    func deleteUser(_ item: User) async throws {
        mockUsers.removeAll(where: { element in element.id == item.id })
    }

    func searchRegisteredUsers(query: String) async throws -> [User] {
        let lower = query.lowercased()
        return allRegisteredUsers.filter { user in
            user.name.lowercased().contains(lower) ||
            user.email.lowercased().contains(lower)
        }
    }
}
