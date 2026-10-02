//
//  CourseEntity.swift
//  LearningDashboard
//
//  Created by Aayush Gandhi on 01/10/26.
//

import Foundation
import SwiftData

@Model
final class CourseEntity {
    @Attribute(.unique) var id: Int
    var title: String
    var instructor: String
    @Relationship(deleteRule: .cascade, inverse: \LessonEntity.course)
    var lessons: [LessonEntity]

    init(id: Int, title: String, instructor: String, lessons: [LessonEntity] = []) {
        self.id = id
        self.title = title
        self.instructor = instructor
        self.lessons = lessons
    }

    func toDomain() -> Course {
        let sortedLessons = lessons
            .sorted(by: { $0.id < $1.id })
            .map { $0.toDomain() }
        
        return Course(
            id: id,
            title: title,
            instructor: instructor,
            lessons: sortedLessons
        )
    }
}
