import SwiftUI

extension View {
    func showAlert(item: Binding<AppAlert?>) -> some View {
        self.alert(
            item.wrappedValue?.title ?? "",
            isPresented: Binding(
                get: { item.wrappedValue != nil },
                set: { newValue in if !newValue { item.wrappedValue = nil } }
            )
        ) {
            if let action = item.wrappedValue?.action,
               let actionTitle = item.wrappedValue?.actionTitle {
                Button(actionTitle, role: .destructive, action: action)
            }
            Button("OK", role: .cancel) { item.wrappedValue = nil }
        } message: {
            if let message = item.wrappedValue?.message {
                Text(message)
            }
        }
    }
}
