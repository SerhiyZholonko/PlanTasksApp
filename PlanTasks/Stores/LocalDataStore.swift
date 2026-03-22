import Foundation

@MainActor
final class LocalDataStore: DataStoreProtocol {
    private let key = "Home_storage"
    // In-memory storage for tasks (no persistence yet)
    private var tasks: [PTask] = []

    func getAllUsers() async throws -> [User] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let items = try? JSONDecoder().decode([User].self, from: data) else {
            return []
        }
        return items
    }

    func addUser(_ item: User) async throws {
        var items = try await getAllUsers()
        items.append(item)
        try save(items)
    }

    func updateUser(_ item: User) async throws {
        var items = try await getAllUsers()
        guard let index = items.firstIndex(where: { element in element.id == item.id }) else {
            throw AppError.notFound
        }
        items[index] = item
        try save(items)
    }

    func deleteUser(_ item: User) async throws {
        var items = try await getAllUsers()
        items.removeAll(where: { element in element.id == item.id })
        try save(items)
    }

    private func save(_ items: [User]) throws {
        guard let data = try? JSONEncoder().encode(items) else {
            throw AppError.saveFailed("Encoding failed")
        }
        UserDefaults.standard.set(data, forKey: key)
    }

    // MARK: - Tasks
    func getAllTasks() async throws -> [PTask] {
        return tasks
    }

    func getAssignedTasks() async throws -> [PTask] {
        return tasks
    }

    func addTask(_ task: PTask) async throws {
        tasks.append(task)
    }

    func updateTask(_ task: PTask) async throws {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            throw AppError.notFound
        }
        tasks[index] = task
    }

    func deleteTask(_ task: PTask) async throws {
        tasks.removeAll { $0.id == task.id }
    }

    // MARK: - Comments (in-memory only)

    private var comments: [String: [TaskComment]] = [:]

    func getComments(taskId: String) async throws -> [TaskComment] {
        comments[taskId] ?? []
    }

    func addComment(_ comment: TaskComment, taskId: String) async throws {
        if comments[taskId] == nil { comments[taskId] = [] }
        comments[taskId]?.append(comment)
    }

    func searchRegisteredUsers(query: String) async throws -> [User] {
        // LocalDataStore searches only among already-saved users (no global registry)
        let all = try await getAllUsers()
        let lower = query.lowercased()
        return all.filter {
            $0.name.lowercased().contains(lower) || $0.email.lowercased().contains(lower)
        }
    }
}
