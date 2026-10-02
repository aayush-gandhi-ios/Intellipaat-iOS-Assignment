//
//  ViewState.swift
//  LearningDashboard
//
//  Created by Aayush Gandhi on 01/10/26.
//

import Foundation

public enum ViewState: Equatable, Sendable {
    case idle
    case loading
    case loaded
    case empty
    case error(String)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
}
