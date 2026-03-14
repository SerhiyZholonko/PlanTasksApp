import Foundation
import Combine
import Factory

@MainActor
final class AppStartingViewModel: ObservableObject {
    @Published var appState: AppState = .home
}
