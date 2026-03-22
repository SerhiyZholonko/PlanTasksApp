//
//  ExpandableFABView.swift
//  PlanTasks
//
//  Created by apple on 12.03.2026.
//


import SwiftUI

struct ExpandableFABView: View {
    @State private var isExpanded = false
    var namespace: Namespace.ID
    var onAddTask: () -> Void = {}
    var onMessage: () -> Void = {}
    var onSettings: () -> Void = {}

    let menuItems: [(icon: String, label: String, color: Color, action: () -> Void)]

    init(namespace: Namespace.ID,
         onAddTask: @escaping () -> Void = {},
         onMessage: @escaping () -> Void = {},
         onSettings: @escaping () -> Void = {}) {
        self.namespace = namespace
        self.onAddTask = onAddTask
        self.onMessage = onMessage
        self.onSettings = onSettings
        self.menuItems = [
            ("plus.circle.fill", "Додати задачу", .green, onAddTask),
//            ("message.fill", "Надіслати повідомлення", .blue, onMessage),
            ("gearshape.fill", "Налаштування", .orange, onSettings),
        ]
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            ForEach(Array(menuItems.enumerated()), id: \.offset) { index, item in
                HStack(spacing: 12) {
                    Text(item.label)
                        .font(.system(size: 15, weight: .semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())

                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            isExpanded = false
                            item.action()
                        }
                    }) {
                        Image(systemName: item.icon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 52, height: 52)
                            .background(item.color)
                            .clipShape(Circle())
                            .shadow(color: item.color.opacity(0.4), radius: 8, y: 4)
                    }
                }
                .opacity(isExpanded ? 1 : 0)
                .scaleEffect(isExpanded ? 1 : 0.5)
                .offset(y: isExpanded ? 0 : 20)
                .animation(.spring(response: 0.4, dampingFraction: 0.7)
                    .delay(Double(menuItems.count - 1 - index) * 0.05),
                    value: isExpanded)
            }

            // Main FAB з matchedGeometryEffect
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isExpanded ? 45 : 0))
                    .frame(width: 64, height: 64)
                    .background(isExpanded ? Color.red : Color.accent)
                    .clipShape(Circle())
                    .shadow(color: (isExpanded ? Color.red : Color.accent).opacity(0.5), radius: 12, y: 6)
            }
            .matchedGeometryEffect(id: "fab", in: namespace)
        }
        .padding(.trailing, 24)
        .padding(.bottom, 40)
    }
}
