//
//  CourseDetailViewModel.swift
//  LearningDashboard
//
//  Created by Aayush Gandhi on 01/10/26.
//

import Foundation
import Observation

/// ViewModel managing a single course's detail view, lesson completion, and SwiftData persistence.
@Observable
@MainActor
public final class CourseDetailViewModel {
    /// Active selected course ID shared across screen transition.
    public static var selectedCourseId: Int = 1

    public private(set) var course: Course
    public private(set) var state: ViewState = .loaded
    public var errorMessage: String?
    public var isContentVisible: Bool = false

    private let persistence: LocalPersistence

    public init(course: Course? = nil, persistence: LocalPersistence? = nil) {
        let activePersistence = persistence ?? .shared
        self.persistence = activePersistence

        if let course = course {
            self.course = course
        } else if let cached = try? activePersistence.fetchCourse(byId: Self.selectedCourseId) {
            self.course = cached
        } else {
            // Default fallback if no course is cached yet
            self.course = Course(
                id: Self.selectedCourseId,
                title: "Course Details",
                instructor: "Instructor",
                lessons: []
            )
        }
    }

    /// Progress percentage computed dynamically from current lessons.
    public var progress: Int {
        course.progress
    }

    /// Progress ratio (0.0 - 1.0) for ProgressView.
    public var progressRatio: Double {
        course.progressRatio
    }

    /// Progress text formatted for display (e.g., "65% Completed").
    public var progressText: String {
        "\(progress)% Completed"
    }

    /// Lessons summary text (e.g. "13 of 20 lessons completed").
    public var lessonsSummaryText: String {
        "\(course.completedLessonCount) of \(course.lessonCount) lessons completed"
    }

    /// Loads the latest state from SwiftData using selectedCourseId.
    public func loadCourse() {
        do {
            if let updated = try persistence.fetchCourse(byId: Self.selectedCourseId) {
                self.course = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        if !isContentVisible {
            isContentVisible = true
        }
    }

    /// Toggles the completion status of a lesson, recalculates progress, and persists locally.
    public func toggleLessonCompletion(lessonId: Int) async {
        guard let index = course.lessons.firstIndex(where: { $0.id == lessonId }) else {
            return
        }

        // Toggle in-memory state
        course.lessons[index].isCompleted.toggle()
        let newStatus = course.lessons[index].isCompleted

        // Persist to SwiftData
        do {
            try persistence.updateLessonCompletion(lessonId: lessonId, isCompleted: newStatus)
            errorMessage = nil
            if newStatus {
                HapticFeedback.success()
            }
        } catch {
            // Revert state if save fails
            course.lessons[index].isCompleted.toggle()
            errorMessage = "Failed to save progress: \(error.localizedDescription)"
            HapticFeedback.error()
        }
    }
}
