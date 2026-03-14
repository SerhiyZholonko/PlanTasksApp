import SwiftUI

extension View {
    func loadingRedacted(when isLoading: Bool) -> some View {
        self
            .redacted(reason: isLoading ? .placeholder : [])
            .allowsHitTesting(!isLoading)
    }
}
