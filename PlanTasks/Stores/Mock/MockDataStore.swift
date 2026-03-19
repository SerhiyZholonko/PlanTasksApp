import Foundation

@MainActor
final class MockDataStore: DataStoreProtocol {

    private let allRegisteredUsers: [User] = User.mockUsers + [
        User(id: UUID().uuidString, name: "Андрій Мороз", email: "andriy@mail.com", phoneNumber: "", avatarInitials: "АМ", consentGiven: true),
        User(id: UUID().uuidString, name: "Оксана Гриценко", email: "oksana@mail.com", phoneNumber: "", avatarInitials: "ОГ", consentGiven: false),
        User(id: UUID().uuidString, name: "Тарас Кравченко", email: "taras@mail.com", phoneNumber: "", avatarInitials: "ТК", consentGiven: true),
        User(id: UUID().uuidString, name: "Юлія Савченко", email: "yulia@mail.com", phoneNumber: "", avatarInitials: "ЮС", consentGiven: true),
        User(id: UUID().uuidString, name: "Богдан Руденко", email: "bohdan@mail.com", phoneNumber: "", avatarInitials: "БР", consentGiven: false),
    ]

    var mockUsers: [User] = User.mockUsers
    var mockTasks: [PTask] = PTask.mockProducts

    func getAllTasks() async throws -> [PTask] { mockTasks }

    func getAssignedTasks() async throws -> [PTask] { mockTasks }

    func addTask(_ task: PTask) async throws { mockTasks.append(task) }

    func updateTask(_ task: PTask) async throws {
        if let i = mockTasks.firstIndex(where: { $0.id == task.id }) { mockTasks[i] = task }
    }

    func deleteTask(_ task: PTask) async throws {
        mockTasks.removeAll { $0.id == task.id }
    }

    func getAllUsers() async throws -> [User] { mockUsers }
    func addUser(_ item: User) async throws { mockUsers.append(item) }
    func updateUser(_ item: User) async throws {
        if let i = mockUsers.firstIndex(where: { $0.id == item.id }) { mockUsers[i] = item }
    }
    func deleteUser(_ item: User) async throws {
        mockUsers.removeAll { $0.id == item.id }
    }

    func searchRegisteredUsers(query: String) async throws -> [User] {
        let lower = query.lowercased()
        return allRegisteredUsers.filter {
            $0.name.lowercased().contains(lower) || $0.email.lowercased().contains(lower)
        }
    }
}
