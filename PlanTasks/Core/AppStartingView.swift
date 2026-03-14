import SwiftUI

struct AppStartingView: View {
    @StateObject private var viewModel = AppStartingViewModel()

    var body: some View {
        Group {
            switch viewModel.appState {
            case .auth:
                AuthView()
            case .home:
                NavigationStack {
                    HomeView()
                }
            }
        }
        .animation(.easeInOut, value: viewModel.appState)
    }
}

#Preview {
    AppStartingView()
}
