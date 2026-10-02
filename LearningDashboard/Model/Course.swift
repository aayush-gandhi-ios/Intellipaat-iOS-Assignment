//
//  Course.swift
//  LearningDashboard
//
//  Created by Aayush Gandhi on 01/10/26.
//

import Foundation

public struct Course: Identifiable, Codable, Equatable, Sendable {
    public let id: Int
    public let title: String
    public let instructor: String
    var lessons: [Lesson]

    init(id: Int, title: String, instructor: String, lessons: [Lesson]) {
        self.id = id
        self.title = title
        self.instructor = instructor
        self.lessons = lessons
    }

    var progress: Int {
        guard !lessons.isEmpty else { return 0 }
        let completedCount = lessons.filter { $0.isCompleted }.count
        let ratio = Double(completedCount) / Double(lessons.count)
        return Int(round(ratio * 100.0))
    }

    var progressRatio: Double {
        guard !lessons.isEmpty else { return 0.0 }
        let completedCount = lessons.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(lessons.count)
    }

    var lessonCount: Int { lessons.count }

    var completedLessonCount: Int { lessons.filter { $0.isCompleted }.count }
}
