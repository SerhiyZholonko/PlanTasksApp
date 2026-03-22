import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class FirebaseDataStore: DataStoreProtocol {

    private let db = Firestore.firestore()

    private var currentUID: String {
        get throws {
            guard let uid = Auth.auth().currentUser?.uid else { throw AppError.unknown }
            return uid
        }
    }

    private func employeesRef(for uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("employees")
    }

    // MARK: - Users (employees)

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

    // MARK: - Tasks (global collection)

    func getAllTasks() async throws -> [PTask] {
        let uid = try currentUID
        let snapshot = try await db.collection("tasks")
            .whereField("createdBy", isEqualTo: uid)
            .getDocuments()
        return snapshot.documents
            .compactMap { PTask(document: $0) }
            .sorted { $0.deadline < $1.deadline }
    }

    func getAssignedTasks() async throws -> [PTask] {
        let uid = try currentUID
        let snapshot = try await db.collection("tasks")
            .whereField("employeeIds", arrayContains: uid)
            .getDocuments()
        return snapshot.documents
            .compactMap { PTask(document: $0) }
            .sorted { $0.deadline < $1.deadline }
    }

    func addTask(_ task: PTask) async throws {
        let uid = try currentUID
        var data = task.firestoreData
        data["createdBy"] = uid
        data["employeeIds"] = task.employees.map { $0.id }
        try await db.collection("tasks").document(task.id).setData(data)
    }

    func updateTask(_ task: PTask) async throws {
        var data = task.firestoreData
        data["employeeIds"] = task.employees.map { $0.id }
        try await db.collection("tasks").document(task.id).setData(data, merge: true)
    }

    func deleteTask(_ task: PTask) async throws {
        try await db.collection("tasks").document(task.id).delete()
    }

    // MARK: - Comments

    private func commentsRef(taskId: String) -> CollectionReference {
        db.collection("tasks").document(taskId).collection("comments")
    }

    func getComments(taskId: String) async throws -> [TaskComment] {
        let snapshot = try await commentsRef(taskId: taskId)
            .order(by: "createdAt", descending: false)
            .getDocuments()
        return snapshot.documents.compactMap { TaskComment(document: $0) }
    }

    func addComment(_ comment: TaskComment, taskId: String) async throws {
        try await commentsRef(taskId: taskId).document(comment.id).setData(comment.firestoreData)
    }
}

// MARK: - Firestore mapping: User

extension User {
    init?(document: QueryDocumentSnapshot) {
        let d = document.data()
        guard let id = d["id"] as? String, let name = d["name"] as? String else { return nil }
        self.init(
            id: id,
            name: name,
            email: d["email"] as? String ?? "",
            phoneNumber: d["phoneNumber"] as? String ?? "",
            avatarInitials: d["avatarInitials"] as? String ?? String(name.prefix(2)).uppercased(),
            consentGiven: d["consentGiven"] as? Bool ?? false
        )
    }

    var firestoreData: [String: Any] {
        ["id": id, "name": name, "email": email, "phoneNumber": phoneNumber,
         "avatarInitials": avatarInitials, "consentGiven": consentGiven]
    }
}

// MARK: - Firestore mapping: TaskComment

extension TaskComment {
    init?(document: QueryDocumentSnapshot) {
        let d = document.data()
        guard let id = d["id"] as? String,
              let authorId = d["authorId"] as? String,
              let authorName = d["authorName"] as? String,
              let text = d["text"] as? String,
              let ts = d["createdAt"] as? Timestamp else { return nil }
        self.init(id: id, authorId: authorId, authorName: authorName,
                  text: text, createdAt: ts.dateValue())
    }

    var firestoreData: [String: Any] {
        ["id": id, "authorId": authorId, "authorName": authorName,
         "text": text, "createdAt": Timestamp(date: createdAt)]
    }
}

// MARK: - Firestore mapping: PTask

extension PTask {
    init?(document: QueryDocumentSnapshot) {
        let d = document.data()
        guard let id = d["id"] as? String,
              let title = d["title"] as? String,
              let ts = d["deadline"] as? Timestamp else { return nil }
        let employeeDicts = d["employees"] as? [[String: Any]] ?? []
        let employees = employeeDicts.compactMap { dict -> User? in
            guard let uid = dict["id"] as? String, let name = dict["name"] as? String else { return nil }
            return User(id: uid, name: name,
                        email: dict["email"] as? String ?? "",
                        phoneNumber: dict["phoneNumber"] as? String ?? "",
                        avatarInitials: dict["avatarInitials"] as? String ?? String(name.prefix(2)).uppercased(),
                        consentGiven: dict["consentGiven"] as? Bool ?? false)
        }
        self.init(id: id, title: title, deadline: ts.dateValue(),
                  isCompleted: d["isCompleted"] as? Bool ?? false, employees: employees)
    }

    var firestoreData: [String: Any] {
        ["id": id, "title": title, "deadline": Timestamp(date: deadline),
         "isCompleted": isCompleted, "employees": employees.map { $0.firestoreData }]
    }
}
