import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        List {
            // User info section
            Section {
                HStack(spacing: 16) {
                    Circle()
                        .fill(Color.appTheme.accent)
                        .frame(width: 64, height: 64)
                        .overlay {
                            Text(viewModel.avatarInitials)
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        if let name = viewModel.user?.displayName, !name.isEmpty {
                            Text(name).font(.headline)
                        }
                        Text(viewModel.userIdentifier)
                            .font(.subheadline)
                            .foregroundStyle(Color.appTheme.secondaryText)
                    }
                }
                .padding(.vertical, 8)

                if viewModel.user?.displayName == nil || viewModel.user?.displayName?.isEmpty == true {
                    Button(action: viewModel.openNameSheet) {
                        Label("Додати ім'я", systemImage: "person.crop.circle.badge.plus")
                    }
                } else {
                    Button(action: viewModel.openNameSheet) {
                        Label("Змінити ім'я", systemImage: "pencil")
                    }
                }
            }

            // Role section
            Section(header: Text("Роль")) {
                Picker("Роль", selection: Binding(
                    get: { viewModel.user?.role ?? .manager },
                    set: { viewModel.updateRole($0) }
                )) {
                    Label("Керівник", systemImage: "briefcase.fill").tag(UserRole.manager)
                    Label("Робітник", systemImage: "hammer.fill").tag(UserRole.worker)
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 4)
            }

            Section {
                Button(role: .destructive, action: viewModel.signOut) {
                    Label("Вийти", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .navigationTitle("Профіль")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showNameSheet) {
            NameEditSheet(viewModel: viewModel)
        }
        .showError(item: $viewModel.error)
    }
}

private struct NameEditSheet: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        NavigationStack {
            Form {
                TextField("Ваше ім'я", text: $viewModel.editingName)
                    .textContentType(.name)
                    .autocorrectionDisabled()
            }
            .navigationTitle("Ім'я")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") { viewModel.showNameSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Зберегти", action: viewModel.saveName)
                        .disabled(viewModel.editingName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .injectMockData()
    }
}
