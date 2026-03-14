//
//  AddTaskView.swift
//  PlanTasks
//
//  Created by apple on 12.03.2026.
//

import SwiftUI

// Приклад AddTaskView — інші вю аналогічно
struct AddTaskView: View {
    @Binding var isPresented: Bool
    var namespace: Namespace.ID

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Нова задача")
                    .font(.title2.bold())
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(24)

            Divider()

            // Content
            VStack(alignment: .leading, spacing: 20) {
                TextField("Назва задачі", text: .constant(""))
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 16))

                TextField("Опис (необов'язково)", text: .constant(""))
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 16))

                Button(action: { withAnimation(.spring()) { isPresented = false } }) {
                    Text("Зберегти")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(24)

            Spacer()
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .shadow(color: .black.opacity(0.15), radius: 30, y: 10)
        .padding(16)
        .matchedGeometryEffect(id: "fab", in: namespace) // ← розкривається з FAB кнопки
        .transition(.opacity)
    }
}
