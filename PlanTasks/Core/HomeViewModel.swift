import Foundation
import Combine
import Factory

@MainActor
final class HomeViewModel: ObservableObject, ErrorDisplayable, AlertDisplayable {

    @Published var users: [User] = []
    @Published var isAddingItem: Bool = false
    @Published var error: Error?
    @Published var alert: AppAlert?
    
    @Published var selectedTab = 0
    @Published var isLoading = true
    @Published var tasks: [PTask] = []
    
    @Published var showAddTask = false
    @Published var showMessage = false
    @Published var showSettings = false


    @Injected(\.dataStore) private var store
    
    init() {
        loadData()
    }

    func loadData() {
        Task(handlingError: self) {
            self.isLoading = true
            defer { self.isLoading = false }
            self.users = try await self.store.getAllUsers()
            self.tasks = try await self.store.getAllTasks()
        }
    }

    func showAddItem() {
        isAddingItem = true
    }

    func deleteUsers(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { index in self.users[index] }
        Task(handlingError: self) {
            for item in itemsToDelete {
                try await self.store.deleteUser(item)
            }
            self.users = try await self.store.getAllUsers()
        }
    }
}
