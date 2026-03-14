import SwiftUI

extension View {
    func infinityFrame(alignment: Alignment = .center) -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }

    func infinityWidth(alignment: Alignment = .center) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }

    @ViewBuilder
    func isHidden(_ hidden: Bool) -> some View {
        if hidden { self.hidden() } else { self }
    }
}
