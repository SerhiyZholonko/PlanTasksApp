import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel = .init()
    @Namespace private var animation

    var body: some View {
        ZStack {
            filterView
//                .task { await loadData() }

            // Відкриті вю
            if viewModel.showAddTask {
                AddTaskView(isPresented: $viewModel.showAddTask, namespace: animation)
                    .zIndex(2)
            }
            if viewModel.showMessage {
                MessageView(isPresented: $viewModel.showMessage, namespace: animation)
                    .zIndex(2)
            }
            if viewModel.showSettings {
                SettingsView(isPresented: $viewModel.showSettings, namespace: animation)
                    .zIndex(2)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if !viewModel.showAddTask && !viewModel.showMessage && !viewModel.showSettings {
                ExpandableFABView(
                    namespace: animation,
                    onAddTask: { withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { viewModel.showAddTask = true } },
                    onMessage: { withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { viewModel.showMessage = true } },
                    onSettings: { withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { viewModel.showSettings = true } }
                )
            }
        }
        .navigationTitle("PlanTasks")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: viewModel.showAddItem) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

private extension HomeView {
    var filterView: some View {
        VStack {
            Picker("", selection: $viewModel.selectedTab) {
                Text("Співробітники").tag(0)
                Text("Задачі").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            List {
                if viewModel.isLoading {
                    ForEach(0..<5, id: \.self) { _ in
                        SkeletonCell()
                    }
                    .listRowSeparator(.hidden)
                } else if viewModel.selectedTab == 0 {
                    ForEach(viewModel.users) { user in
                        UserCell(user: user)
                    }
                } else {
                    ForEach(viewModel.tasks) { task in
                        ProductCell(product: task)
                    }
                }
            }
            .listStyle(.plain)
            .animation(.default, value: viewModel.isLoading)
        }
    }

    func loadData() async {
        await viewModel.loadData()
    }
}
#Preview {
    NavigationStack {
        HomeView()
            .injectMockData()
    }
}














