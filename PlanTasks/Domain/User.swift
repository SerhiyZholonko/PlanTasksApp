//
//  User.swift
//  PlanTasks
//
//  Created by apple on 12.03.2026.
//


import SwiftUI

struct User: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String
    let email: String
    let phoneNumber: String
    let avatarInitials: String
}
extension User {
    static let mockUsers: [User] = [
        User(id: UUID().uuidString, name: "Олексій Коваль", email: "oleksiy@mail.com", phoneNumber: "", avatarInitials: "ОК"),
        User(id: UUID().uuidString, name: "Марія Шевченко", email: "maria@mail.com", phoneNumber: "", avatarInitials: "МШ"),
        User(id: UUID().uuidString, name: "Іван Петренко", email: "ivan@mail.com", phoneNumber: "", avatarInitials: "ІП"),
        User(id: UUID().uuidString, name: "Наталія Бондар", email: "natalia@mail.com", phoneNumber: "", avatarInitials: "НБ"),
        User(id: UUID().uuidString, name: "Дмитро Лисенко", email: "dmytro@mail.com", phoneNumber: "", avatarInitials: "ДЛ"),
    ]
}
