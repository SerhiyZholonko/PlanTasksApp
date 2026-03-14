//
//  PTask.swift
//  PlanTasks
//
//  Created by apple on 12.03.2026.
//


import SwiftUI

struct PTask: Identifiable {
    let id: UUID
    let title: String
    let redLineDate: Date
    var isCompleted: Bool = false
    let employee: User
    
}
extension PTask {
    static let mockProducts: [PTask] = [
        PTask(id: UUID(), title: "MacBook Pro 16\"", redLineDate: Date().addingTimeInterval(60*60*24*3), employee: User.mockUsers.first!),
        PTask(id: UUID(), title: "iPhone 15 Pro", redLineDate: Date().addingTimeInterval(60*60*24*7), employee: User.mockUsers[1]),
        PTask(id: UUID(), title: "AirPods Pro", redLineDate: Date().addingTimeInterval(60*60*24*10), employee: User.mockUsers[2]),
        PTask(id: UUID(), title: "iPad Air", redLineDate: Date().addingTimeInterval(60*60*24*14), employee: User.mockUsers[3]),
        PTask(id: UUID(), title: "Apple Watch Ultra", redLineDate: Date().addingTimeInterval(60*60*24*21), employee: User.mockUsers[4]),
    ]
}
