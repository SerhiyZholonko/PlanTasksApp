import Foundation

@MainActor
protocol DataStoreProtocol: AnyObject {

    func getAllUsers() async throws -> [User]
    func addUser(_ user: User) async throws
    func updateUser(_ user: User) async throws
    func deleteUser(_ user: User) async throws
    func searchRegisteredUsers(query: String) async throws -> [User]

    func getAllTasks() async throws -> [PTask]        // manager: tasks I created
    func getAssignedTasks() async throws -> [PTask]  // worker: tasks assigned to me
    func addTask(_ task: PTask) async throws
    func updateTask(_ task: PTask) async throws
    func deleteTask(_ task: PTask) async throws

    func getComments(taskId: String) async throws -> [TaskComment]
    func addComment(_ comment: TaskComment, taskId: String) async throws
}
