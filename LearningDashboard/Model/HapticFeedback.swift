//
//  HapticFeedback.swift
//  LearningDashboard
//
//  Created by Aayush Gandhi on 01/10/26.
//

import UIKit

@MainActor
enum HapticFeedback {
    /// Generates light tactile impact for general button taps and selections.
    public static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Generates medium tactile impact for primary actions (e.g. Sign In, Navigation).
    public static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Generates success notification haptic (e.g. successful login, lesson completed).
    public static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    /// Generates warning notification haptic (e.g. entering offline mode).
    public static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    /// Generates error notification haptic (e.g. validation failure, network error).
    public static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
}
