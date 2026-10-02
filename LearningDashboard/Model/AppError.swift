//
//  AppError.swift
//  LearningDashboard
//
//  Created by Aayush Gandhi on 01/10/26.
//

import Foundation

public enum AppError: LocalizedError, Equatable, Sendable {
    case emptyEmail
    case invalidEmail
    case emptyPassword
    case passwordTooShort
    case invalidCredentials
    case networkUnavailable
    case serverError(String)
    case invalidResponse
    case noCachedData
    case decodingFailed
    case persistenceFailed(String)

    public var errorDescription: String? {
        switch self {
        case .emptyEmail:
            return "Email cannot be empty."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .emptyPassword:
            return "Password cannot be empty."
        case .passwordTooShort:
            return "Password must be at least 6 characters."
        case .invalidCredentials:
            return "Unable to login. Please check your credentials."
        case .networkUnavailable:
            return "Unable to load courses. Please check your internet connection."
        case .serverError(let message):
            return "Server error: \(message)"
        case .invalidResponse:
            return "Invalid server response."
        case .noCachedData:
            return "No cached courses available offline."
        case .decodingFailed:
            return "Failed to parse course data."
        case .persistenceFailed(let message):
            return "Unable to save progress: \(message)"
        }
    }
}
