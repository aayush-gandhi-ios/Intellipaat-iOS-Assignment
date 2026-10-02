//
//  LoginViewModel.swift
//  LearningDashboard
//
//  Created by Aayush Gandhi on 01/10/26.
//

import Foundation
import Observation

/// ViewModel managing login screen state, validation, authentication, and navigation.
@Observable
@MainActor
public final class LoginViewModel {
    public var email: String = "student@learning.com"
    public var password: String = "password123"
    public var state: ViewState = .idle
    public var isAuthenticated: Bool = false
    public var navigationPath: [String] = []
    public var currentUser: User?
    public var isPasswordVisible: Bool = false

    private let apiClient: CourseAPIClient

    public init(apiClient: CourseAPIClient = .shared) {
        self.apiClient = apiClient
    }

    /// Toggles password visibility and triggers light haptic feedback.
    public func togglePasswordVisibility() {
        isPasswordVisible.toggle()
        HapticFeedback.light()
    }

    /// Validates input credentials and returns a localized error if invalid.
    public func validateInput() -> AppError? {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            return .emptyEmail
        }

        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}$"#
        guard trimmedEmail.range(of: emailRegex, options: .regularExpression) != nil else {
            return .invalidEmail
        }

        guard !password.isEmpty else {
            return .emptyPassword
        }

        guard password.count >= 6 else {
            return .passwordTooShort
        }

        return nil
    }

    /// Executes login with validation, async API simulation, error handling, and state updates.
    public func login() async {
        if let validationError = validateInput() {
            state = .error(validationError.localizedDescription)
            HapticFeedback.error()
            return
        }

        state = .loading

        do {
            let user = try await apiClient.login(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
            currentUser = user
            state = .loaded
            isAuthenticated = true
            HapticFeedback.success()
            navigationPath.append("dashboard")
        } catch let appError as AppError {
            state = .error(appError.localizedDescription)
            HapticFeedback.error()
        } catch {
            state = .error(error.localizedDescription)
            HapticFeedback.error()
        }
    }

    /// Resets error state if user changes input.
    public func clearError() {
        if case .error = state {
            state = .idle
        }
    }
}
