//
//  SettingsView.swift
//  PlanTasks
//
//  Created by apple on 12.03.2026.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    var namespace: Namespace.ID

    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var soundEnabled = true

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: "gearshape.fill")
                                .foregroundStyle(.orange)
                        }
                    Text("Налаштування")
                        .font(.title2.bold())
                }
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

            // Settings list
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "bell.fill",
                    iconColor: .red,
                    title: "Сповіщення",
                    subtitle: "Push-повідомлення"
                ) {
                    Toggle("", isOn: $notificationsEnabled)
                        .labelsHidden()
                }

                Divider().padding(.leading, 60)

                SettingsRow(
                    icon: "moon.fill",
                    iconColor: .indigo,
                    title: "Темна тема",
                    subtitle: "Змінити вигляд застосунку"
                ) {
                    Toggle("", isOn: $darkModeEnabled)
                        .labelsHidden()
                }

                Divider().padding(.leading, 60)

                SettingsRow(
                    icon: "speaker.wave.2.fill",
                    iconColor: .blue,
                    title: "Звуки",
                    subtitle: "Звукові ефекти"
                ) {
                    Toggle("", isOn: $soundEnabled)
                        .labelsHidden()
                }

                Divider().padding(.leading, 60)

                SettingsRow(
                    icon: "person.fill",
                    iconColor: .green,
                    title: "Профіль",
                    subtitle: "Редагувати дані"
                ) {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }

                Divider().padding(.leading, 60)

                SettingsRow(
                    icon: "questionmark.circle.fill",
                    iconColor: .orange,
                    title: "Підтримка",
                    subtitle: "Зв'язатися з нами"
                ) {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 8)

            Spacer()

            // Version
            Text("PlanTasks v1.0.0")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .shadow(color: .black.opacity(0.15), radius: 30, y: 10)
        .padding(16)
        .matchedGeometryEffect(id: "fab", in: namespace)
        .transition(.opacity)
    }
}

// Helper view для рядка налаштувань
struct SettingsRow<Trailing: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 10)
                .fill(iconColor.opacity(0.15))
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(iconColor)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            trailing()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
}
