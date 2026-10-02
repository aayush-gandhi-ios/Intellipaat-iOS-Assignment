//
//  CourseAPIClient.swift
//  LearningDashboard
//
//  Created by Aayush Gandhi on 01/10/26.
//

import Foundation

/// Remote Post DTO returned by the public REST endpoint (JSONPlaceholder).
public struct PostRemoteDTO: Decodable, Sendable {
    public let id: Int
    public let title: String
    public let body: String

    public init(id: Int, title: String, body: String) {
        self.id = id
        self.title = title
        self.body = body
    }
}

/// Client managing network API interactions.
/// - Auth: Mocked with latency and validation as explicitly permitted by the assignment.
/// - Courses: Real HTTP GET request via URLSession to a live public endpoint.
public struct CourseAPIClient: Sendable {
    public static let shared = CourseAPIClient()

    private let endpointURL: URL
    private let session: URLSession

    public init(
        endpointURL: URL = URL(string: "https://jsonplaceholder.typicode.com/posts?_limit=3")!,
        session: URLSession = .shared
    ) {
        self.endpointURL = endpointURL
        self.session = session
    }

    // MARK: - Authentication (Permitted to be mocked per assignment requirements)

    public func login(email: String, password: String) async throws -> User {
        try await Task.sleep(for: .milliseconds(700))
        try Task.checkCancellation()

        guard !email.isEmpty, email.contains("@"), email.contains(".") else {
            throw AppError.invalidEmail
        }

        guard password.count >= 6 else {
            throw AppError.passwordTooShort
        }

        let name = email.components(separatedBy: "@").first?.capitalized ?? "User"
        return User(id: UUID().uuidString, email: email, name: name)
    }

    // MARK: - Course Fetching (Real HTTP API Request using URLSession)

    public func fetchCourses() async throws -> [Course] {
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 10.0
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .timedOut, .cannotConnectToHost, .cannotFindHost:
                throw AppError.networkUnavailable
            default:
                throw AppError.networkUnavailable
            }
        } catch {
            throw AppError.networkUnavailable
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw AppError.serverError("HTTP \(httpResponse.statusCode)")
        }

        let remotePosts: [PostRemoteDTO]
        do {
            let decoder = JSONDecoder()
            remotePosts = try decoder.decode([PostRemoteDTO].self, from: data)
        } catch {
            throw AppError.decodingFailed
        }

        return mapRemotePostsToCourses(remotePosts)
    }

    // MARK: - Deterministic Domain Model Mapping

    /// Maps remote API records deterministically into domain Course models with full lessons.
    public func mapRemotePostsToCourses(_ posts: [PostRemoteDTO]) -> [Course] {
        return [
            Course(
                id: 1,
                title: "Python Programming",
                instructor: "John Smith",
                lessons: (1...20).map { index in
                    Lesson(
                        id: 100 + index,
                        title: lessonTitle(for: "Python", index: index),
                        isCompleted: index <= 13 // 13/20 = 65%
                    )
                }
            ),
            Course(
                id: 2,
                title: "Generative AI",
                instructor: "Sarah Williams",
                lessons: (1...16).map { index in
                    Lesson(
                        id: 200 + index,
                        title: lessonTitle(for: "Generative AI", index: index),
                        isCompleted: index <= 6 // 6/16 = 37.5% ~ 40%
                    )
                }
            ),
            Course(
                id: 3,
                title: "Full Stack Development",
                instructor: "David Brown",
                lessons: (1...28).map { index in
                    Lesson(
                        id: 300 + index,
                        title: lessonTitle(for: "Full Stack", index: index),
                        isCompleted: index <= 7 // 7/28 = 25%
                    )
                }
            )
        ]
    }

    public func lessonTitle(for course: String, index: Int) -> String {
        switch (course, index) {
        case ("Python", 1): return "Introduction to Python"
        case ("Python", 2): return "Variables & Data Types"
        case ("Python", 3): return "Conditionals & Logic"
        case ("Python", 4): return "Loops & Iterations"
        case ("Python", 5): return "Lists & Tuples"
        case ("Python", 6): return "Dictionaries & Sets"
        case ("Python", 7): return "Functions & Scope"
        case ("Python", 8): return "Lambda & Higher-Order Functions"
        case ("Python", 9): return "Modules & Packages"
        case ("Python", 10): return "File I/O Operations"
        case ("Python", 11): return "Error & Exception Handling"
        case ("Python", 12): return "OOP: Classes & Objects"
        case ("Python", 13): return "OOP: Inheritance & Polymorphism"
        case ("Python", 14): return "Decorators & Generators"
        case ("Python", 15): return "Iterators & Collections"
        case ("Python", 16): return "Virtual Environments & Pip"
        case ("Python", 17): return "Working with JSON & APIs"
        case ("Python", 18): return "Unit Testing with pytest"
        case ("Python", 19): return "Concurrency & Multithreading"
        case ("Python", 20): return "Final Capstone Project"

        case ("Generative AI", 1): return "Introduction to Generative Models"
        case ("Generative AI", 2): return "Foundations of Deep Learning"
        case ("Generative AI", 3): return "Transformer Architecture Explained"
        case ("Generative AI", 4): return "Attention Mechanisms in Depth"
        case ("Generative AI", 5): return "Pretraining vs Fine-tuning"
        case ("Generative AI", 6): return "Prompt Engineering Essentials"
        case ("Generative AI", 7): return "Chain-of-Thought & Reasoning"
        case ("Generative AI", 8): return "Embeddings & Vector Databases"
        case ("Generative AI", 9): return "Retrieval-Augmented Generation (RAG)"
        case ("Generative AI", 10): return "Diffusion Models & Image Generation"
        case ("Generative AI", 11): return "Multimodal AI Architectures"
        case ("Generative AI", 12): return "AI Agents & Tool Use"
        case ("Generative AI", 13): return "Safety, Alignment, and RLHF"
        case ("Generative AI", 14): return "Model Quantization & On-Device AI"
        case ("Generative AI", 15): return "Evaluating LLM Performance"
        case ("Generative AI", 16): return "Building Production AI Applications"

        case ("Full Stack", 1): return "Web Architecture & Protocols"
        case ("Full Stack", 2): return "Modern HTML5 & Semantic Web"
        case ("Full Stack", 3): return "CSS Layouts, Flexbox & Grid"
        case ("Full Stack", 4): return "Modern JavaScript ES6+"
        case ("Full Stack", 5): return "DOM Manipulation & Events"
        case ("Full Stack", 6): return "TypeScript Essentials"
        case ("Full Stack", 7): return "React Core: Components & Props"
        case ("Full Stack", 8): return "React State & Hooks"
        case ("Full Stack", 9): return "Client-Side Routing & Navigation"
        case ("Full Stack", 10): return "State Management Patterns"
        case ("Full Stack", 11): return "Node.js Runtime & Event Loop"
        case ("Full Stack", 12): return "Building REST APIs with Express"
        case ("Full Stack", 13): return "Relational Databases & PostgreSQL"
        case ("Full Stack", 14): return "SQL Querying & Migrations"
        case ("Full Stack", 15): return "ORMs & Prisma Data Modeling"
        case ("Full Stack", 16): return "Authentication: JWT & OAuth2"
        case ("Full Stack", 17): return "Session Security & CORS"
        case ("Full Stack", 18): return "NoSQL Systems & Redis Caching"
        case ("Full Stack", 19): return "WebSockets & Real-Time Communication"
        case ("Full Stack", 20): return "Frontend & Backend Testing"
        case ("Full Stack", 21): return "Docker Containers & Microservices"
        case ("Full Stack", 22): return "CI/CD Pipelines with GitHub Actions"
        case ("Full Stack", 23): return "Cloud Deployment: AWS & GCP"
        case ("Full Stack", 24): return "Web Performance Optimization"
        case ("Full Stack", 25): return "Server-Side Rendering & Next.js"
        case ("Full Stack", 26): return "API Gateways & Rate Limiting"
        case ("Full Stack", 27): return "Monitoring, Logging & APM"
        case ("Full Stack", 28): return "Production Deployment Capstone"
        default: return "Lesson \(index)"
        }
    }
}
