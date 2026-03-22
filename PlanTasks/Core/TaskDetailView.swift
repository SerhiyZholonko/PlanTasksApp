import SwiftUI

struct TaskDetailView: View {
    @StateObject var viewModel: TaskDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                taskInfoSection
                if viewModel.isManager {
                    completeButton
                }
                employeesSection
                Divider()
                commentsSection
            }
            .padding()
        }
        .navigationTitle(viewModel.isEditing ? "Редагування" : viewModel.task.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .onAppear { viewModel.loadComments() }
        .showError(item: $viewModel.error)
    }
}

// MARK: - Task Info

private extension TaskDetailView {
    var taskInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.isEditing {
                TextField("Назва задачі", text: $viewModel.editedTitle)
                    .font(.title3.bold())
                    .textFieldStyle(.roundedBorder)

                DatePicker("Дедлайн", selection: $viewModel.editedDeadline, displayedComponents: .date)
                    .font(.subheadline)
            } else {
                Text(viewModel.task.title)
                    .font(.title3.bold())
                    .foregroundStyle(Color.appTheme.text)

                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .foregroundStyle(deadlineColor)
                    Text(viewModel.task.deadline, style: .date)
                        .font(.subheadline)
                        .foregroundStyle(deadlineColor)
                    Text("·")
                        .foregroundStyle(Color.appTheme.secondaryText)
                    Text(daysLabel)
                        .font(.subheadline)
                        .foregroundStyle(deadlineColor)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.appTheme.cellBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    var deadlineColor: Color {
        if viewModel.task.isCompleted { return Color.appTheme.success }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: viewModel.task.deadline).day ?? 0
        if days < 0 { return Color.appTheme.destructive }
        if days <= 2 { return Color.appTheme.warning }
        return Color.appTheme.secondaryText
    }

    var daysLabel: String {
        if viewModel.task.isCompleted { return "виконано" }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: viewModel.task.deadline).day ?? 0
        if days < 0 { return "прострочено" }
        if days == 0 { return "сьогодні" }
        if days == 1 { return "завтра" }
        return "\(days) д."
    }
}

// MARK: - Complete Button

private extension TaskDetailView {
    var completeButton: some View {
        Button(action: viewModel.toggleCompleted) {
            HStack {
                Image(systemName: viewModel.task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                Text(viewModel.task.isCompleted ? "Позначити як не виконану" : "Позначити як виконану")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(viewModel.task.isCompleted ? Color.appTheme.secondaryText : .white)
            .background(viewModel.task.isCompleted ? Color.appTheme.cellBackground : Color.appTheme.success)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

// MARK: - Employees

private extension TaskDetailView {
    var employeesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Виконавці")
                .font(.subheadline.bold())
                .foregroundStyle(Color.appTheme.secondaryText)

            ForEach(viewModel.task.employees) { employee in
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color.appTheme.accent)
                        .frame(width: 36, height: 36)
                        .overlay {
                            Text(employee.avatarInitials)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(employee.name)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.appTheme.text)
                        if !employee.email.isEmpty {
                            Text(employee.email)
                                .font(.caption)
                                .foregroundStyle(Color.appTheme.secondaryText)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.appTheme.cellBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Comments

private extension TaskDetailView {
    var commentsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Коментарі (\(viewModel.comments.count))")
                .font(.subheadline.bold())
                .foregroundStyle(Color.appTheme.secondaryText)

            if viewModel.isLoadingComments {
                HStack { Spacer(); ProgressView(); Spacer() }
            } else if viewModel.comments.isEmpty {
                Text("Коментарів поки немає")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTheme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                ForEach(viewModel.comments) { comment in
                    CommentBubble(comment: comment)
                }
            }

            commentInput
        }
    }

    var commentInput: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Написати коментар...", text: $viewModel.newCommentText, axis: .vertical)
                .lineLimit(1...4)
                .padding(10)
                .background(Color.appTheme.cellBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Button(action: viewModel.addComment) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(viewModel.newCommentText.trimmingCharacters(in: .whitespaces).isEmpty
                                     ? Color.appTheme.secondaryText
                                     : Color.appTheme.accent)
            }
            .disabled(viewModel.newCommentText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
}

// MARK: - Toolbar

private extension TaskDetailView {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        if viewModel.isManager {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.isEditing {
                    HStack {
                        Button("Скасувати", action: viewModel.cancelEditing)
                            .foregroundStyle(Color.appTheme.secondaryText)
                        Button("Зберегти") {
                            viewModel.saveEdits()
                        }
                        .fontWeight(.semibold)
                        .disabled(viewModel.isSaving)
                    }
                } else {
                    Button {
                        viewModel.editedTitle = viewModel.task.title
                        viewModel.editedDeadline = viewModel.task.deadline
                        viewModel.isEditing = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
        }
    }
}

// MARK: - Comment Bubble

private struct CommentBubble: View {
    let comment: TaskComment

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.authorName)
                    .font(.caption.bold())
                    .foregroundStyle(Color.appTheme.accent)
                Spacer()
                Text(comment.createdAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(Color.appTheme.secondaryText)
            }
            Text(comment.text)
                .font(.subheadline)
                .foregroundStyle(Color.appTheme.text)
        }
        .padding(12)
        .background(Color.appTheme.cellBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(
            viewModel: TaskDetailViewModel(task: PTask.mockProducts[0], isManager: true)
        )
        .injectMockData()
    }
}
