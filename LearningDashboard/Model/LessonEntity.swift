//
//  LessonEntity.swift
//  LearningDashboard
//
//  Created by Aayush Gandhi on 01/10/26.
//

import Foundation
import SwiftData

@Model
final class LessonEntity {
    @Attribute(.unique) public var id: Int
    var title: String
    var isCompleted: Bool
    var course: CourseEntity?

    init(id: Int, title: String, isCompleted: Bool, course: CourseEntity? = nil) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.course = course
    }

    func toDomain() -> Lesson {
        Lesson(id: id, title: title, isCompleted: isCompleted)
    }
}
