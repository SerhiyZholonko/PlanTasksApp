//
//  User.swift
//  PlanTasks
//
//  Created by apple on 12.03.2026.
//


import SwiftUI

struct User: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let name: String
    let email: String
    let avatarInitials: String
}
extension User {
    static let mockUsers: [User] = [
        User(id: UUID(), name: "Олексій Коваль", email: "oleksiy@mail.com", avatarInitials: "ОК"),
        User(id: UUID(), name: "Марія Шевченко", email: "maria@mail.com", avatarInitials: "МШ"),
        User(id: UUID(), name: "Іван Петренко", email: "ivan@mail.com", avatarInitials: "ІП"),
        User(id: UUID(), name: "Наталія Бондар", email: "natalia@mail.com", avatarInitials: "НБ"),
        User(id: UUID(), name: "Дмитро Лисенко", email: "dmytro@mail.com", avatarInitials: "ДЛ"),
    ]
}
