import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        List {
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
                            Text(name)
                                .font(.headline)
                        }
                        Text(viewModel.user?.email ?? "")
                            .font(.subheadline)
                            .foregroundStyle(Color.appTheme.secondaryText)
                    }
                }
                .padding(.vertical, 8)
            }

            Section {
                Button(role: .destructive, action: viewModel.signOut) {
                    Label("Вийти", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .navigationTitle("Профіль")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .injectMockData()
    }
}
