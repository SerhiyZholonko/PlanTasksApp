import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel = .init()
    @Namespace private var animation

    var body: some View {
        ZStack {
            if viewModel.isManager {
                managerView
            } else {
                workerView
            }

            if viewModel.showAddTask {
                AddTaskView(isPresented: $viewModel.showAddTask, namespace: animation) {
                    viewModel.loadData()
                }
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
            if viewModel.isManager && !viewModel.showAddTask && !viewModel.showMessage && !viewModel.showSettings {
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
                HStack {
                    if viewModel.isManager && viewModel.selectedTab == 0 {
                        Button { viewModel.showAddEmployee = true } label: {
                            Image(systemName: "person.badge.plus").font(.title3)
                        }
                    }
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle").font(.title3)
                    }
                }
            }
        }
    }
}

// MARK: - Manager view

private extension HomeView {
    var managerView: some View {
        VStack {
            Picker("", selection: $viewModel.selectedTab) {
                Text("Співробітники").tag(0)
                Text("Задачі").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            List {
                if viewModel.isLoading {
                    ForEach(0..<5, id: \.self) { _ in SkeletonCell() }
                        .listRowSeparator(.hidden)
                } else if viewModel.selectedTab == 0 {
                    ForEach(viewModel.users) { user in UserCell(user: user) }
                        .onDelete(perform: viewModel.deleteUsers)
                } else {
                    ForEach(viewModel.tasks) { task in
                        NavigationLink(destination: TaskDetailView(
                            viewModel: TaskDetailViewModel(task: task, isManager: viewModel.isManager, onTaskUpdated: viewModel.updateTask)
                        )) {
                            ProductCell(product: task)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.plain)
            .animation(.default, value: viewModel.isLoading)
        }
        .sheet(isPresented: $viewModel.showAddEmployee) {
            AddEmployeeSheet(viewModel: viewModel)
        }
    }
}

// MARK: - Worker view

private extension HomeView {
    var workerView: some View {
        Group {
            if !viewModel.consentGiven {
                consentView
            } else {
                workerTaskList
            }
        }
    }

    var workerTaskList: some View {
        List {
            if viewModel.isLoading {
                ForEach(0..<5, id: \.self) { _ in SkeletonCell() }
                    .listRowSeparator(.hidden)
            } else if viewModel.tasks.isEmpty {
                ContentUnavailableView("Немає задач", systemImage: "checkmark.circle",
                    description: Text("Керівники ще не призначили вам задач"))
            } else {
                ForEach(viewModel.tasks) { task in
                    NavigationLink(destination: TaskDetailView(
                        viewModel: TaskDetailViewModel(task: task, isManager: viewModel.isManager, onTaskUpdated: viewModel.updateTask)
                    )) {
                        ProductCell(product: task)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .listStyle(.plain)
        .animation(.default, value: viewModel.isLoading)
    }

    var consentView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 72))
                .foregroundStyle(Color.appTheme.accent)

            VStack(spacing: 8) {
                Text("Надайте згоду")
                    .font(.title2.bold())
                Text("Щоб керівники могли призначати вам задачі, потрібна ваша одноразова згода.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button(action: viewModel.grantConsent) {
                Text("Надати згоду")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appTheme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)

            Spacer()
        }
    }
}

// MARK: - Add Employee Sheet

private struct AddEmployeeSheet: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        NavigationStack {
            List {
                if viewModel.isSearching {
                    HStack { Spacer(); ProgressView(); Spacer() }
                } else if viewModel.searchResults.isEmpty && !viewModel.searchQuery.isEmpty {
                    Text("Нікого не знайдено")
                        .foregroundStyle(Color.appTheme.secondaryText)
                } else {
                    ForEach(viewModel.searchResults) { user in
                        HStack {
                            UserCell(user: user)
                            Spacer()
                            Button {
                                viewModel.addEmployee(user)
                            } label: {
                                Image(systemName: "person.badge.plus")
                                    .foregroundStyle(Color.appTheme.accent)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $viewModel.searchQuery, prompt: "Ім'я або пошта")
            .onChange(of: viewModel.searchQuery) { viewModel.searchEmployees() }
            .navigationTitle("Додати співробітника")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрити") {
                        viewModel.showAddEmployee = false
                        viewModel.searchQuery = ""
                        viewModel.searchResults = []
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView().injectMockData()
    }
}
