//
//  LocalPersistence.swift
//  LearningDashboard
//
//  Created by Aayush Gandhi on 01/10/26.
//

import Foundation
import SwiftData

@MainActor
public final class LocalPersistence {
    public static let shared = LocalPersistence()

    let modelContainer: ModelContainer
    var modelContext: ModelContext { modelContainer.mainContext }

    init(isInMemoryOnly: Bool = false) {
        do {
            let schema = Schema([
                CourseEntity.self,
                LessonEntity.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isInMemoryOnly)
            self.modelContainer = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error.localizedDescription)")
        }
    }

    func fetchCachedCourses() throws -> [Course] {
        let descriptor = FetchDescriptor<CourseEntity>(sortBy: [SortDescriptor(\.id, order: .forward)])
        let entities = try modelContext.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }

    func saveCourses(_ courses: [Course]) throws {
        for course in courses {
            let courseId = course.id
            var fetchDescriptor = FetchDescriptor<CourseEntity>(
                predicate: #Predicate { $0.id == courseId }
            )
            fetchDescriptor.fetchLimit = 1

            let existing = try modelContext.fetch(fetchDescriptor)

            if let existingCourse = existing.first {
                existingCourse.title = course.title
                existingCourse.instructor = course.instructor

                for lesson in course.lessons {
                    if let existingLesson = existingCourse.lessons.first(where: { $0.id == lesson.id }) {
                        existingLesson.title = lesson.title
                        // Existing completion status is preserved to retain local progress
                    } else {
                        let newLesson = LessonEntity(
                            id: lesson.id,
                            title: lesson.title,
                            isCompleted: lesson.isCompleted,
                            course: existingCourse
                        )
                        modelContext.insert(newLesson)
                        existingCourse.lessons.append(newLesson)
                    }
                }
            } else {
                let courseEntity = CourseEntity(
                    id: course.id,
                    title: course.title,
                    instructor: course.instructor
                )
                modelContext.insert(courseEntity)

                for lesson in course.lessons {
                    let lessonEntity = LessonEntity(
                        id: lesson.id,
                        title: lesson.title,
                        isCompleted: lesson.isCompleted,
                        course: courseEntity
                    )
                    modelContext.insert(lessonEntity)
                    courseEntity.lessons.append(lessonEntity)
                }
            }
        }
        try modelContext.save()
    }

    func updateLessonCompletion(lessonId: Int, isCompleted: Bool) throws {
        var fetchDescriptor = FetchDescriptor<LessonEntity>(
            predicate: #Predicate { $0.id == lessonId }
        )
        fetchDescriptor.fetchLimit = 1

        let lessons = try modelContext.fetch(fetchDescriptor)
        guard let lesson = lessons.first else {
            throw AppError.persistenceFailed("Lesson with ID \(lessonId) not found in local store.")
        }

        lesson.isCompleted = isCompleted
        try modelContext.save()
    }

    func fetchCourse(byId id: Int) throws -> Course? {
        var fetchDescriptor = FetchDescriptor<CourseEntity>(
            predicate: #Predicate { $0.id == id }
        )
        fetchDescriptor.fetchLimit = 1

        let courses = try modelContext.fetch(fetchDescriptor)
        return courses.first?.toDomain()
    }

    func clearAllData() throws {
        try modelContext.delete(model: LessonEntity.self)
        try modelContext.delete(model: CourseEntity.self)
        try modelContext.save()
    }
}
