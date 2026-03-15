import Foundation
import Combine
import Factory

@MainActor
final class AppStartingViewModel: ObservableObject {
    @Injected(\.authStore) private var authStore
    @Published var appState: AppState = .auth

    init() {
        authStore.currentUserPublisher
            .map { $0 != nil ? AppState.home : .auth }
            .assign(to: &$appState)
    }

    func signOut() {
        try? authStore.signOut()
    }
}
