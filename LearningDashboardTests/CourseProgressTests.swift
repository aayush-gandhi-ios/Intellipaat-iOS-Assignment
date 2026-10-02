//
//  CourseProgressTests.swift
//  LearningDashboard
//
//  Created by Aayush Gandhi on 01/10/26.
//

import XCTest
@testable import LearningDashboard

final class CourseProgressTests: XCTestCase {

    // MARK: - Progress Calculation Tests

    func testProgressWithZeroLessonsReturnsZero() {
        // Arrange
        let course = Course(
            id: 1,
            title: "Empty Course",
            instructor: "Test Instructor",
            lessons: []
        )

        // Act & Assert
        XCTAssertEqual(course.progress, 0, "Progress for 0 lessons must be 0%")
        XCTAssertEqual(course.progressRatio, 0.0, "Progress ratio for 0 lessons must be 0.0")
        XCTAssertEqual(course.lessonCount, 0)
        XCTAssertEqual(course.completedLessonCount, 0)
    }

    func testProgressWithFourLessonsTwoCompletedReturnsFiftyPercent() {
        // Arrange
        let lessons = [
            Lesson(id: 1, title: "Lesson 1", isCompleted: true),
            Lesson(id: 2, title: "Lesson 2", isCompleted: true),
            Lesson(id: 3, title: "Lesson 3", isCompleted: false),
            Lesson(id: 4, title: "Lesson 4", isCompleted: false)
        ]
        let course = Course(
            id: 2,
            title: "Halfway Course",
            instructor: "Test Instructor",
            lessons: lessons
        )

        // Act & Assert
        XCTAssertEqual(course.progress, 50, "4 lessons with 2 completed must equal 50%")
        XCTAssertEqual(course.progressRatio, 0.5, accuracy: 0.001)
        XCTAssertEqual(course.lessonCount, 4)
        XCTAssertEqual(course.completedLessonCount, 2)
    }

    func testProgressWithAllLessonsCompletedReturnsOneHundredPercent() {
        // Arrange
        let lessons = [
            Lesson(id: 1, title: "Lesson 1", isCompleted: true),
            Lesson(id: 2, title: "Lesson 2", isCompleted: true)
        ]
        let course = Course(
            id: 3,
            title: "Completed Course",
            instructor: "Test Instructor",
            lessons: lessons
        )

        // Act & Assert
        XCTAssertEqual(course.progress, 100, "All completed lessons must equal 100%")
        XCTAssertEqual(course.progressRatio, 1.0, accuracy: 0.001)
    }

    func testProgressWithNoLessonsCompletedReturnsZeroPercent() {
        // Arrange
        let lessons = [
            Lesson(id: 1, title: "Lesson 1", isCompleted: false),
            Lesson(id: 2, title: "Lesson 2", isCompleted: false)
        ]
        let course = Course(
            id: 4,
            title: "Unstarted Course",
            instructor: "Test Instructor",
            lessons: lessons
        )

        // Act & Assert
        XCTAssertEqual(course.progress, 0)
        XCTAssertEqual(course.progressRatio, 0.0, accuracy: 0.001)
    }

    // MARK: - Login Validation Tests

    @MainActor
    func testLoginValidationEmptyEmail() {
        let viewModel = LoginViewModel()
        viewModel.email = ""
        viewModel.password = "password123"

        let error = viewModel.validateInput()
        XCTAssertEqual(error, .emptyEmail)
    }

    @MainActor
    func testLoginValidationInvalidEmail() {
        let viewModel = LoginViewModel()
        viewModel.email = "not-an-email"
        viewModel.password = "password123"

        let error = viewModel.validateInput()
        XCTAssertEqual(error, .invalidEmail)
    }

    @MainActor
    func testLoginValidationShortPassword() {
        let viewModel = LoginViewModel()
        viewModel.email = "valid@example.com"
        viewModel.password = "123"

        let error = viewModel.validateInput()
        XCTAssertEqual(error, .passwordTooShort)
    }

    @MainActor
    func testLoginValidationSuccess() {
        let viewModel = LoginViewModel()
        viewModel.email = "valid@example.com"
        viewModel.password = "password123"

        let error = viewModel.validateInput()
        XCTAssertNil(error, "Valid credentials should return nil error")
    }

    @MainActor
    func testLoginPasswordVisibilityToggle() {
        let viewModel = LoginViewModel()
        XCTAssertFalse(viewModel.isPasswordVisible, "Password should default to hidden")

        viewModel.togglePasswordVisibility()
        XCTAssertTrue(viewModel.isPasswordVisible, "Password should be visible after toggle")

        viewModel.togglePasswordVisibility()
        XCTAssertFalse(viewModel.isPasswordVisible, "Password should be hidden after second toggle")
    }

    // MARK: - SwiftData Persistence & Toggle Tests

    @MainActor
    func testCourseDetailViewModelToggleLessonUpdatesProgress() async {
        let persistence = LocalPersistence(isInMemoryOnly: true)
        let initialLessons = [
            Lesson(id: 10, title: "Swift Basics", isCompleted: false),
            Lesson(id: 11, title: "Swift Advanced", isCompleted: false)
        ]
        let initialCourse = Course(id: 99, title: "Swift Course", instructor: "Apple", lessons: initialLessons)

        try? persistence.saveCourses([initialCourse])

        let viewModel = CourseDetailViewModel(course: initialCourse, persistence: persistence)
        XCTAssertEqual(viewModel.progress, 0)

        // Toggle first lesson
        await viewModel.toggleLessonCompletion(lessonId: 10)
        XCTAssertEqual(viewModel.progress, 50)
        XCTAssertTrue(viewModel.course.lessons[0].isCompleted)

        // Toggle second lesson
        await viewModel.toggleLessonCompletion(lessonId: 11)
        XCTAssertEqual(viewModel.progress, 100)
        XCTAssertTrue(viewModel.course.lessons[1].isCompleted)

        // Toggle first lesson back to incomplete
        await viewModel.toggleLessonCompletion(lessonId: 10)
        XCTAssertEqual(viewModel.progress, 50)
        XCTAssertFalse(viewModel.course.lessons[0].isCompleted)
    }

    // MARK: - Dashboard Offline Fallback & Real Network Tests

    @MainActor
    func testDashboardLoadsCachedDataWhenOffline() async {
        let persistence = LocalPersistence(isInMemoryOnly: true)
        let cachedLessons = [Lesson(id: 1, title: "L1", isCompleted: true)]
        let cachedCourse = Course(id: 50, title: "Cached Course", instructor: "Instructor", lessons: cachedLessons)
        try? persistence.saveCourses([cachedCourse])

        // Unreachable local port causes real URLSession connection failure
        let offlineAPI = CourseAPIClient(endpointURL: URL(string: "http://127.0.0.1:65534/unavailable")!)
        let dashboardVM = CourseDashboardViewModel(apiClient: offlineAPI, persistence: persistence)

        await dashboardVM.loadCourses()

        XCTAssertEqual(dashboardVM.courses.count, 1)
        XCTAssertEqual(dashboardVM.courses.first?.title, "Cached Course")
        XCTAssertEqual(dashboardVM.state, .loaded)
        XCTAssertTrue(dashboardVM.isOffline)
    }

    @MainActor
    func testDashboardFreshInstallOfflineShowsErrorState() async {
        let persistence = LocalPersistence(isInMemoryOnly: true)
        // No cached courses in store

        let offlineAPI = CourseAPIClient(endpointURL: URL(string: "http://127.0.0.1:65534/unavailable")!)
        let dashboardVM = CourseDashboardViewModel(apiClient: offlineAPI, persistence: persistence)

        await dashboardVM.loadCourses()

        XCTAssertTrue(dashboardVM.courses.isEmpty)
        XCTAssertTrue(dashboardVM.isOffline)
        if case .error(let message) = dashboardVM.state {
            XCTAssertEqual(message, "Unable to load courses. Please check your internet connection.")
        } else {
            XCTFail("Expected .error state when offline with no cache, got \(dashboardVM.state)")
        }
    }

    func testAPIClientRealHTTPFetchAndMapping() async throws {
        let client = CourseAPIClient()
        let courses = try await client.fetchCourses()

        XCTAssertEqual(courses.count, 3)
        XCTAssertEqual(courses[0].title, "Python Programming")
        XCTAssertEqual(courses[0].instructor, "John Smith")
        XCTAssertEqual(courses[0].lessonCount, 20)
        XCTAssertEqual(courses[0].progress, 65)

        XCTAssertEqual(courses[1].title, "Generative AI")
        XCTAssertEqual(courses[1].instructor, "Sarah Williams")
        XCTAssertEqual(courses[1].lessonCount, 16)

        XCTAssertEqual(courses[2].title, "Full Stack Development")
        XCTAssertEqual(courses[2].instructor, "David Brown")
        XCTAssertEqual(courses[2].lessonCount, 28)
    }
}
