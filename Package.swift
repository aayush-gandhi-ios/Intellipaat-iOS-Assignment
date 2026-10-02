// swift-tools-version: 5.9
//
//  Package.swift
//  LearningDashboard
//
//  Created by Aayush Gandhi on 01/10/26.
//

import PackageDescription

let package = Package(
    name: "LearningDashboard",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "LearningDashboard",
            targets: ["LearningDashboard"]
        ),
    ],
    targets: [
        .target(
            name: "LearningDashboard",
            path: "LearningDashboard",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "LearningDashboardTests",
            dependencies: ["LearningDashboard"],
            path: "LearningDashboardTests"
        ),
    ]
)
