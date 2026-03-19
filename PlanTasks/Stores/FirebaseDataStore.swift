import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class FirebaseDataStore: DataStoreProtocol {

    private let db = Firestore.firestore()
    private var tasks: [PTask] = []

    // MARK: - Helpers

    private var currentUID: String {
        get throws {
            guard let uid = Auth.auth().currentUser?.uid else { throw AppError.unknown }
            return uid
        }
    }

    private func employeesRef(for uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("employees")
    }

    // MARK: - Users (employees of current user)

    func getAllUsers() async throws -> [User] {
        let uid = try currentUID
        let snapshot = try await employeesRef(for: uid).getDocuments()
        return snapshot.documents.compactMap { User(document: $0) }
    }

    func addUser(_ user: User) async throws {
        let uid = try currentUID
        try await employeesRef(for: uid).document(user.id).setData(user.firestoreData)
    }

    func updateUser(_ user: User) async throws {
        let uid = try currentUID
        try await employeesRef(for: uid).document(user.id).setData(user.firestoreData, merge: true)
    }

    func deleteUser(_ user: User) async throws {
        let uid = try currentUID
        try await employeesRef(for: uid).document(user.id).delete()
    }

    func searchRegisteredUsers(query: String) async throws -> [User] {
        let lower = query.lowercased()
        let snapshot = try await db.collection("registeredUsers").getDocuments()
        let currentUID = try self.currentUID
        return snapshot.documents
            .compactMap { User(document: $0) }
            .filter { $0.id != currentUID }
            .filter {
                $0.name.lowercased().contains(lower) ||
                $0.email.lowercased().contains(lower) ||
                $0.phoneNumber.contains(lower)
            }
    }

    // MARK: - Tasks (in-memory, Firestore wiring TBD)

    func getAllTasks() async throws -> [PTask] { tasks }

    func addTask(_ task: PTask) async throws {
        tasks.append(task)
    }

    func updateTask(_ task: PTask) async throws {
        guard let i = tasks.firstIndex(where: { $0.id == task.id }) else { throw AppError.notFound }
        tasks[i] = task
    }

    func deleteTask(_ task: PTask) async throws {
        tasks.removeAll { $0.id == task.id }
    }
}

// MARK: - Firestore mapping

private extension User {
    init?(document: QueryDocumentSnapshot) {
        let d = document.data()
        guard let id = d["id"] as? String,
              let name = d["name"] as? String else { return nil }
        self.init(
            id: id,
            name: name,
            email: d["email"] as? String ?? "",
            phoneNumber: d["phoneNumber"] as? String ?? "",
            avatarInitials: d["avatarInitials"] as? String ?? String(name.prefix(2)).uppercased()
        )
    }

    var firestoreData: [String: Any] {
        ["id": id, "name": name, "email": email, "phoneNumber": phoneNumber, "avatarInitials": avatarInitials]
    }
}
