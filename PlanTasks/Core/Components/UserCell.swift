//
//  UserCell.swift
//  PlanTasks
//
//  Created by apple on 12.03.2026.
//


import SwiftUI

struct UserCell: View {
    let user: User

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 44, height: 44)
                Text(user.avatarInitials)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(user.name)
                    .font(.system(size: 15, weight: .medium))
                Text(user.email)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}