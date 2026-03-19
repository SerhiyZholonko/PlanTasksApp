import Foundation
import Combine
import Factory

@MainActor
final class AddTaskViewModel: ObservableObject, ErrorDisplayable {

    @Injected(\.dataStore) private var store

    @Published var title: String = ""
    @Published var deadline: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @Published var selectedEmployees: Set<User> = []
    @Published var employees: [User] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?

    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && !selectedEmployees.isEmpty
    }

    func loadEmployees() {
        Task(handlingError: self) {
            self.employees = try await self.store.getAllUsers()
        }
    }

    func toggleEmployee(_ user: User) {
        if selectedEmployees.contains(user) {
            selectedEmployees.remove(user)
        } else {
            selectedEmployees.insert(user)
        }
    }

    func save() async throws {
        let task = PTask(
            id: UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespaces),
            deadline: deadline,
            isCompleted: false,
            employees: Array(selectedEmployees)
        )
        try await store.addTask(task)
    }
}
