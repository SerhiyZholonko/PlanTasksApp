import SwiftUI

struct ProductCell: View {
    let product: PTask

    private var deadlineColor: Color {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: product.deadline).day ?? 0
        if product.isCompleted { return Color.appTheme.success }
        if days < 0 { return Color.appTheme.destructive }
        if days <= 2 { return Color.appTheme.warning }
        return Color.appTheme.secondaryText
    }

    private var deadlineIcon: String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: product.deadline).day ?? 0
        if product.isCompleted { return "checkmark.circle.fill" }
        if days < 0 { return "exclamationmark.circle.fill" }
        if days <= 2 { return "clock.fill" }
        return "calendar"
    }

    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(deadlineColor.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: deadlineIcon)
                        .foregroundStyle(deadlineColor)
                        .font(.system(size: 18))
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.system(size: 15, weight: .medium))
                    .strikethrough(product.isCompleted)
                    .foregroundStyle(product.isCompleted ? Color.appTheme.secondaryText : Color.appTheme.text)

                // Employee avatars
                HStack(spacing: -6) {
                    ForEach(product.employees.prefix(4)) { employee in
                        Circle()
                            .fill(Color.appTheme.accent)
                            .frame(width: 22, height: 22)
                            .overlay {
                                Text(employee.avatarInitials)
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .overlay { Circle().stroke(Color.appTheme.viewBackground, lineWidth: 1.5) }
                    }
                    if product.employees.count > 4 {
                        Circle()
                            .fill(Color.appTheme.cellBackground)
                            .frame(width: 22, height: 22)
                            .overlay {
                                Text("+\(product.employees.count - 4)")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(Color.appTheme.secondaryText)
                            }
                            .overlay { Circle().stroke(Color.appTheme.viewBackground, lineWidth: 1.5) }
                    }
                }
            }

            Spacer()

            // Deadline
            VStack(alignment: .trailing, spacing: 2) {
                Text(product.deadline, style: .date)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(deadlineColor)
                Text(daysLabel)
                    .font(.system(size: 11))
                    .foregroundStyle(deadlineColor.opacity(0.8))
            }
        }
        .padding(.vertical, 4)
    }

    private var daysLabel: String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: product.deadline).day ?? 0
        if product.isCompleted { return "виконано" }
        if days < 0 { return "прострочено" }
        if days == 0 { return "сьогодні" }
        if days == 1 { return "завтра" }
        return "\(days) д."
    }
}
