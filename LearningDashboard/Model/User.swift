//
//  User.swift
//  LearningDashboard
//
//  Created by Aayush Gandhi on 01/10/26.
//

import Foundation

public struct User: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let email: String
    public let name: String

    public init(id: String = UUID().uuidString, email: String, name: String) {
        self.id = id
        self.email = email
        self.name = name
    }
}
