//
//  ProductCell.swift
//  PlanTasks
//
//  Created by apple on 12.03.2026.
//


import SwiftUI

struct ProductCell: View {
    let product: PTask

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "shippingbox")
                    .foregroundColor(.orange)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(product.title)
                    .font(.system(size: 15, weight: .medium))
                Text(product.employee.name)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(product.redLineDate, style: .date)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}