//
//  Lesson.swift
//  LearningDashboard
//
//  Created by Aayush Gandhi on 01/10/26.
//

import Foundation

struct Lesson: Identifiable, Codable, Equatable, Sendable {
    let id: Int
    let title: String
    var isCompleted: Bool

    init(id: Int, title: String, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}
