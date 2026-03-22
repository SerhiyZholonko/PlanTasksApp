import Foundation
import Combine
import Factory

@MainActor
final class TaskDetailViewModel: ObservableObject, ErrorDisplayable {

    @Published var task: PTask
    @Published var comments: [TaskComment] = []
    @Published var newCommentText = ""
    @Published var isLoadingComments = false
    @Published var isSaving = false
    @Published var error: Error?

    // Editing (manager only)
    @Published var isEditing = false
    @Published var editedTitle: String
    @Published var editedDeadline: Date

    let isManager: Bool

    @Injected(\.dataStore) private var store
    @Injected(\.authStore) private var authStore

    init(task: PTask, isManager: Bool) {
        self.task = task
        self.isManager = isManager
        self.editedTitle = task.title
        self.editedDeadline = task.deadline
    }

    func loadComments() {
        Task(handlingError: self) {
            self.isLoadingComments = true
            defer { self.isLoadingComments = false }
            self.comments = try await self.store.getComments(taskId: self.task.id)
        }
    }

    func addComment() {
        let text = newCommentText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        guard let user = authStore.currentUser else { return }

        let comment = TaskComment(
            id: UUID().uuidString,
            authorId: user.id,
            authorName: user.displayName ?? user.email,
            text: text,
            createdAt: Date()
        )
        newCommentText = ""
        Task(handlingError: self) {
            try await self.store.addComment(comment, taskId: self.task.id)
            self.comments.append(comment)
        }
    }

    func toggleCompleted() {
        guard isManager else { return }
        Task(handlingError: self) {
            var updated = self.task
            updated.isCompleted.toggle()
            try await self.store.updateTask(updated)
            self.task = updated
        }
    }

    func saveEdits() {
        guard isManager else { return }
        let title = editedTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        Task(handlingError: self) {
            self.isSaving = true
            defer { self.isSaving = false }
            var updated = self.task
            updated.title = title
            updated.deadline = self.editedDeadline
            try await self.store.updateTask(updated)
            self.task = updated
            self.isEditing = false
        }
    }

    func cancelEditing() {
        editedTitle = task.title
        editedDeadline = task.deadline
        isEditing = false
    }
}
