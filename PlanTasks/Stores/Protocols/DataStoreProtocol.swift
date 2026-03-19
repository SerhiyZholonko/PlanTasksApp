import Foundation

@MainActor
protocol DataStoreProtocol: AnyObject {
    
    func getAllUsers() async throws -> [User]
    func addUser(_ user: User) async throws
    func updateUser(_ user: User) async throws
    func deleteUser(_ user: User) async throws
    func searchRegisteredUsers(query: String) async throws -> [User]
    
    func getAllTasks() async throws -> [PTask]
    func addTask(_ task: PTask) async throws
    func updateTask(_ task: PTask) async throws
    func deleteTask(_ task: PTask) async throws
}
