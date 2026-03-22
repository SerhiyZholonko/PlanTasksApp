import Foundation
import Combine
import Factory

@MainActor
final class HomeViewModel: ObservableObject, ErrorDisplayable, AlertDisplayable {

    @Published var users: [User] = []
    @Published var tasks: [PTask] = []
    @Published var error: Error?
    @Published var alert: AppAlert?
    @Published var selectedTab = 0
    @Published var isLoading = true
    @Published var currentUser: AppUser?

    @Published var showAddTask = false
    @Published var showMessage = false
    @Published var showSettings = false
    @Published var showAddEmployee = false
    @Published var searchQuery = ""
    @Published var searchResults: [User] = []
    @Published var isSearching = false

    @Injected(\.dataStore) private var store
    @Injected(\.authStore) private var authStore

    private var cancellables = Set<AnyCancellable>()

    init() {
        authStore.currentUserPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.currentUser = user
                self?.loadData()
            }
            .store(in: &cancellables)
    }

    var isManager: Bool { currentUser?.role == .manager }
    var consentGiven: Bool { currentUser?.consentGiven == true }

    func loadData() {
        Task(handlingError: self) {
            self.isLoading = true
            defer { self.isLoading = false }
            if self.isManager {
                self.users = try await self.store.getAllUsers()
                self.tasks = try await self.store.getAllTasks()
            } else {
                self.tasks = try await self.store.getAssignedTasks()
            }
        }
    }

    func grantConsent() {
        Task(handlingError: self) {
            try await self.authStore.grantConsent()
            self.tasks = try await self.store.getAssignedTasks()
        }
    }

    func deleteUsers(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { self.users[$0] }
        Task(handlingError: self) {
            for item in itemsToDelete { try await self.store.deleteUser(item) }
            self.users = try await self.store.getAllUsers()
        }
    }

    func updateTask(_ task: PTask) {
        if let i = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[i] = task
        }
    }

    func toggleTaskCompleted(_ task: PTask) {
        Task(handlingError: self) {
            var updated = task
            updated.isCompleted.toggle()
            try await self.store.updateTask(updated)
            if let i = self.tasks.firstIndex(where: { $0.id == task.id }) {
                self.tasks[i] = updated
            }
        }
    }

    func searchEmployees() {
        let query = searchQuery.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { searchResults = []; return }
        Task(handlingError: self) {
            self.isSearching = true
            defer { self.isSearching = false }
            let results = try await self.store.searchRegisteredUsers(query: query)
            self.searchResults = results.filter { found in !self.users.contains(where: { $0.id == found.id }) }
        }
    }

    func addEmployee(_ user: User) {
        Task(handlingError: self) {
            try await self.store.addUser(user)
            self.users = try await self.store.getAllUsers()
            self.searchResults.removeAll { $0.id == user.id }
        }
    }
}
