//
//  CourseDashboardViewModel.swift
//  LearningDashboard
//
//  Created by Aayush Gandhi on 01/10/26.
//

import Foundation
import Observation

/// ViewModel managing the Course Dashboard screen: data loading, offline fallback, caching,
/// error handling, and navigation destination creation.
@Observable
@MainActor
public final class CourseDashboardViewModel {
    public private(set) var courses: [Course] = []
    public private(set) var state: ViewState = .idle
    public private(set) var isOffline: Bool = false
    public var shouldNavigateToDetail: Bool = false
    public var isContentVisible: Bool = false

    private let apiClient: CourseAPIClient
    private let persistence: LocalPersistence

    public init(apiClient: CourseAPIClient = .shared, persistence: LocalPersistence? = nil) {
        self.apiClient = apiClient
        self.persistence = persistence ?? .shared
    }

    /// Loads course data according to the required offline-first strategy:
    /// 1. Check local SwiftData cache.
    /// 2. If cached data exists, display it immediately.
    /// 3. Attempt to fetch fresh data via REAL URLSession HTTP request.
    /// 4. On API success: update SwiftData cache & refresh UI.
    /// 5. On API failure: if cached data exists -> keep showing cache; if no cached data -> show error state.
    public func loadCourses() async {
        // Step 1: Check cached courses
        let cached = (try? persistence.fetchCachedCourses()) ?? []
        if !cached.isEmpty {
            self.courses = cached
            self.state = .loaded
        } else {
            self.state = .loading
        }

        // Step 2: Perform REAL URLSession API request
        do {
            let remoteCourses = try await apiClient.fetchCourses()

            // Update SwiftData cache (preserving locally completed lessons)
            try persistence.saveCourses(remoteCourses)

            // Re-fetch from persistence to ensure state is synchronized with stored lesson status
            let updatedCourses = try persistence.fetchCachedCourses()
            self.courses = updatedCourses
            self.isOffline = false

            if self.courses.isEmpty {
                self.state = .empty
            } else {
                self.state = .loaded
            }
        } catch {
            // Step 3: Handle Network Error
            if !self.courses.isEmpty {
                // Cached courses exist -> keep cache visible
                self.isOffline = true
                self.state = .loaded
            } else {
                // No cached courses available -> show user-facing error state
                self.isOffline = true
                let message = (error as? LocalizedError)?.errorDescription ?? "Unable to load courses. Please check your internet connection."
                self.state = .error(message)
            }
        }
    }

    /// Selects a course to navigate to details by configuring CourseDetailViewModel's selectedCourseId
    /// and triggering navigation state.
    public func selectCourse(_ course: Course) {
        CourseDetailViewModel.selectedCourseId = course.id
        shouldNavigateToDetail = true
    }

    /// Called when screen appears or returning from CourseDetail to synchronize updated lesson progress on the dashboard.
    public func onAppear() {
        refreshAfterReturning()
        if !isContentVisible {
            isContentVisible = true
        }
    }

    public func refreshAfterReturning() {
        if let cached = try? persistence.fetchCachedCourses(), !cached.isEmpty {
            self.courses = cached
        }
    }
}
