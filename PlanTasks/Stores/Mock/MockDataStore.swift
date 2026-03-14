import Foundation

@MainActor
final class MockDataStore: DataStoreProtocol {
    
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
}
