import SwiftUI

struct AddTaskView: View {
    @Binding var isPresented: Bool
    var namespace: Namespace.ID
    var onSaved: () -> Void

    @StateObject private var viewModel = AddTaskViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Нова задача")
                    .font(.title2.bold())
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(24)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Назва
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Назва задачі", systemImage: "pencil")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color.appTheme.secondaryText)
                        TextField("Введіть назву", text: $viewModel.title)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Дедлайн
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Дедлайн", systemImage: "calendar")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color.appTheme.secondaryText)
                        DatePicker("", selection: $viewModel.deadline, in: Date()..., displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .tint(Color.appTheme.accent)
                    }

                    // Співробітники
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Співробітники", systemImage: "person.2")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color.appTheme.secondaryText)

                        if viewModel.employees.isEmpty {
                            Text("Немає доданих співробітників")
                                .font(.subheadline)
                                .foregroundStyle(Color.appTheme.secondaryText)
                                .padding(.vertical, 8)
                        } else {
                            ForEach(viewModel.employees) { employee in
                                let isSelected = viewModel.selectedEmployees.contains(employee)
                                Button {
                                    viewModel.toggleEmployee(employee)
                                } label: {
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(isSelected ? Color.appTheme.accent : Color.appTheme.cellBackground)
                                            .frame(width: 40, height: 40)
                                            .overlay {
                                                Text(employee.avatarInitials)
                                                    .font(.system(size: 13, weight: .semibold))
                                                    .foregroundStyle(isSelected ? .white : Color.appTheme.text)
                                            }
                                        Text(employee.name)
                                            .font(.system(size: 15))
                                            .foregroundStyle(Color.appTheme.text)
                                        Spacer()
                                        if isSelected {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Color.appTheme.accent)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(.plain)
                                Divider()
                            }
                        }
                    }

                    // Кнопка зберегти
                    Button {
                        Task {
                            viewModel.isLoading = true
                            defer { viewModel.isLoading = false }
                            do {
                                try await viewModel.save()
                                onSaved()
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    isPresented = false
                                }
                            } catch {
                                viewModel.error = error
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Зберегти")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isFormValid ? Color.appTheme.accent : Color.appTheme.secondaryText.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                }
                .padding(24)
            }
        }
        .background(Color.appTheme.viewBackground)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .shadow(color: .black.opacity(0.15), radius: 30, y: 10)
        .padding(16)
        .matchedGeometryEffect(id: "fab", in: namespace)
        .transition(.opacity)
        .showError(item: $viewModel.error)
        .onAppear { viewModel.loadEmployees() }
    }
}
