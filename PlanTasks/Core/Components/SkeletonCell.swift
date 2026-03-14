//
//  SkeletonCell.swift
//  PlanTasks
//
//  Created by apple on 12.03.2026.
//


import SwiftUI

struct SkeletonCell: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .frame(height: 14)
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: 120, height: 12)
            }
        }
        .foregroundColor(.gray.opacity(0.3))
        .opacity(isAnimating ? 0.4 : 1.0)
        .animation(.easeInOut(duration: 0.9).repeatForever(), value: isAnimating)
        .onAppear { isAnimating = true }
        .padding(.vertical, 4)
    }
}