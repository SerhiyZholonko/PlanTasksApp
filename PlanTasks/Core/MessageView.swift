//
//  MessageView.swift
//  PlanTasks
//
//  Created by apple on 12.03.2026.
//

import SwiftUI

struct MessageView: View {
    @Binding var isPresented: Bool
    var namespace: Namespace.ID
    @State private var messageText = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: "message.fill")
                                .foregroundStyle(.blue)
                        }
                    Text("Повідомлення")
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

            // Recipients
            VStack(alignment: .leading, spacing: 8) {
                Text("Кому")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(["ОК", "МШ", "ІП"], id: \.self) { initials in
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(Color.blue.opacity(0.15))
                                    .frame(width: 48, height: 48)
                                    .overlay {
                                        Text(initials)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(.blue)
                                    }
                                Text(initials)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        // Add recipient
                        VStack(spacing: 4) {
                            Circle()
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1.5)
                                .frame(width: 48, height: 48)
                                .overlay {
                                    Image(systemName: "plus")
                                        .foregroundStyle(.secondary)
                                }
                            Text("Додати")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Divider()
                .padding(.top, 20)

            // Message input
            VStack(alignment: .leading, spacing: 8) {
                Text("Повідомлення")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextEditor(text: $messageText)
                    .frame(height: 120)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        if messageText.isEmpty {
                            Text("Введіть повідомлення...")
                                .foregroundStyle(.tertiary)
                                .padding(18)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .allowsHitTesting(false)
                        }
                    }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            // Send button
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    isPresented = false
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "paperplane.fill")
                    Text("Надіслати")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Spacer()
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .shadow(color: .black.opacity(0.15), radius: 30, y: 10)
        .padding(16)
        .matchedGeometryEffect(id: "fab", in: namespace)
        .transition(.opacity)
    }
}
