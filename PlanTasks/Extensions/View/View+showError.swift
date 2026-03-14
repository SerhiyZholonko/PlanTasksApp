import SwiftUI

extension View {
    func showError(item: Binding<Error?>) -> some View {
        self.alert("Error", isPresented: Binding(
            get: { item.wrappedValue != nil },
            set: { newValue in if !newValue { item.wrappedValue = nil } }
        )) {
            Button("OK", role: .cancel) { item.wrappedValue = nil }
        } message: {
            Text(item.wrappedValue?.localizedDescription ?? "")
        }
    }
}
