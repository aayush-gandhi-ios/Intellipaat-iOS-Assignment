# iOS Technical Assignment
**Author:** Aayush Gandhi

LearningDashboard is an iOS application built with **Swift, SwiftUI, MVVM, Swift Concurrency (`async`/`await`), and SwiftData**. It provides an offline-first course learning experience with credentials validation, interactive course tracking, dynamic lesson progress calculation, real HTTP networking with public REST APIs, and local persistence.

---

## Tech Stack

- **Swift 5.9+**
- **SwiftUI** (Declarative User Interface)
- **MVVM** (Model-View-ViewModel architecture with Apple's modern `@Observable` macro)
- **SwiftData** (Local offline persistence and model caching)
- **URLSession** (Type-safe asynchronous HTTP networking)
- **Swift Concurrency** (`async`/`await`, `Task`, `@MainActor`)

---

## Features

- **Authentication (Login)**: Client-side validation for email formats and password length, password visibility toggle (show/hide), and simulated authentication flow.
- **Course Dashboard**: Displays enrolled courses, instructor metadata, total lesson counts, and dynamic progress bars.
- **Course Details**: Full syllabus view displaying individual lesson topics and interactive completion checkboxes with haptic feedback.
- **Lesson Completion**: Toggle lessons as completed or incomplete with instant recalculation of course progress.
- **Dynamic Progress Calculation**: Single source of truth derived dynamically (`completedLessons / totalLessons × 100`).
- **Real API Request**: Live HTTP GET request via `URLSession` to a public REST endpoint (`JSONPlaceholder`).
- **State Handling**: Comprehensive states for `.idle`, `.loading`, `.loaded`, `.empty`, and `.error(String)`.
- **SwiftData Offline Persistence**: Cache-first offline storage storing courses and lessons locally.
- **Real Network Failure Fallback**: Graceful fallback displaying cached courses and preserved progress when network connectivity drops.
- **Retry Support**: Dedicated retry action to recover from network errors once connectivity is restored.

---

## Architecture

The project strictly follows the **MVVM (Model-View-ViewModel)** architectural pattern:

```text
LearningDashboard/
├── Model/
│   ├── Course.swift
│   ├── Lesson.swift
│   ├── User.swift
│   ├── ViewState.swift
│   ├── AppError.swift
│   ├── CourseEntity.swift
│   ├── LessonEntity.swift
│   ├── LocalPersistence.swift
│   ├── CourseAPIClient.swift
│   └── HapticFeedback.swift
├── View/
│   ├── LoginView.swift
│   ├── CourseDashboardView.swift
│   └── CourseDetailView.swift
└── ViewModel/
    ├── LoginViewModel.swift
    ├── CourseDashboardViewModel.swift
    └── CourseDetailViewModel.swift
```

### Why MVVM was Selected:
- **Clean Separation of Concerns**: Views are purely declarative rendering layers with zero business logic, zero direct networking, and zero persistence logic.
- **Strict View Rule**: Every screen View owns **only one stored property** (`@State private var viewModel = ...`), preventing state leakage and UI-logic coupling.
- **Modern Observation**: Uses Swift's `@Observable` macro from the `Observation` framework, enabling fine-grained property-level view invalidation without `ObservableObject` overhead.
- **High Testability**: All business logic (validation, progress calculation, cache fallback, error mapping) resides in ViewModels and pure models, allowing complete unit testing without UI dependencies.
- **Single Source of Truth**: Progress is computed dynamically rather than stored redundantly across multiple places.

---

## Offline Support

Offline capability is implemented using **SwiftData** following a resilient cache-first approach:

```text
SwiftData cache → URLSession refresh → update cache on success → retain cached data on network failure
```

1. **Check SwiftData Cache**: When `CourseDashboardView` appears, the app first queries `LocalPersistence.fetchCachedCourses()`. If cached data exists, it renders immediately.
2. **URLSession Refresh**: In the background, `CourseAPIClient.fetchCourses()` performs a real HTTP GET request to the remote endpoint.
3. **Update Cache on Success**: On successful response, courses are updated in SwiftData while preserving local lesson completion states.
4. **Retain Cached Data on Network Failure**: When internet connectivity is unavailable (`URLError.notConnectedToInternet`, lost connection, or timeout), previously cached SwiftData courses and lesson progress remain visible, and an offline status banner is displayed.
5. **Fresh Install Offline State**: If the app is launched for the first time without internet and has no cached data, it displays `"Unable to load courses. Please check your internet connection."` with a **Retry** button.
6. **Mock Authentication**: Login authentication remains intentionally mocked with simulated latency and validation, as permitted by the assessment requirements.

---

## Security

- In a production environment, authentication tokens (JWT, refresh tokens) and user credentials must be stored securely in the **iOS Keychain** via the `Security` framework or `LocalAuthentication`, using `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`.
- Sensitive tokens should never be stored in `UserDefaults`, unencrypted property lists, or source code.
- Production network communication must enforce HTTPS with **SSL/TLS Certificate Pinning** (via `URLSessionDelegate`) to defend against man-in-the-middle attacks.

---

## Scaling

To scale this application for large enterprise user bases:

- **Pagination & Lazy Loading**: Replace full catalog loading with cursor-based pagination (e.g., 20 courses per page) to optimize memory and network bandwidth.
- **Improved Caching & Synchronization**: Implement HTTP `ETag` / `If-None-Match` conditional requests (`304 Not Modified`) to save battery and network usage.
- **Backend & Server-Side Filtering**: Provide search, filtering, and categorization on the server to minimize client payload sizes.
- **Networking Retry with Exponential Backoff**: Implement jittered exponential backoff for resilient recovery during network instability.
- **Observability & Crash Monitoring**: Integrate structured logging, OpenTelemetry, and crash monitoring (e.g., MetricKit) to track network latency and app performance.

---

## Android Equivalent

An equivalent enterprise implementation on Android maps as follows:

| iOS (Swift / SwiftUI) | Android Equivalent | Note |
|---|---|---|
| **SwiftUI** | Jetpack Compose | Modern declarative UI framework |
| **ViewModel state (`@Observable`)** | Android `ViewModel` + `StateFlow` / `SharedFlow` | Reactive UI state management |
| **Swift Concurrency (`async`/`await`)** | Kotlin Coroutines (`suspend fun`) | Structured asynchronous execution |
| **URLSession / CourseAPIClient** | Retrofit / Ktor Client | Type-safe HTTP REST client |
| **SwiftData** | Room Persistence Library | SQLite object mapping abstraction |
| **iOS Keychain** | Android Keystore / EncryptedSharedPreferences | Hardware-backed cryptographic security |
| **XCTest** | JUnit 5 + MockK + Turbine | Unit and state flow testing |

---

## Running the Project

### Requirements
- **macOS Sonoma (14.0+)** or later
- **Xcode 15.0+**
- **iOS 17.0+** Simulator or physical device

### Instructions
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd Intellipaat-iOS-Assignment
   ```
2. Open `LearningDashboard.xcodeproj` in Xcode.
3. Select an iOS Simulator (e.g., **iPhone 16** or **iPhone 16 Pro** running iOS 17.0+).
4. Press `Cmd + R` to Build and Run.

---

## Testing Offline Behaviour

You can manually verify real network failure handling and SwiftData offline fallback:

1. **Run with Internet**:
   - Launch the application on the simulator.
   - Tap **Sign In** (demo credentials pre-filled).
   - Dashboard loads courses from the live API and saves them to SwiftData.
2. **Complete a Lesson**:
   - Tap **Continue** on any course (e.g., *Python Programming*).
   - Tap a lesson checkbox to toggle its completion status (observe dynamic progress recalculation and haptic feedback).
   - Tap the back button. The dashboard reflects the updated progress.
3. **Disable Internet**:
   - Turn off Wi-Fi on your host Mac / disable internet.
4. **Refresh or Relaunch**:
   - Pull-to-refresh on the Course Dashboard or relaunch the app.
   - `URLSession` attempts the real API request and catches the connection failure.
   - Previously cached SwiftData courses and all updated lesson progress remain visible, with an orange offline indicator.
5. **Fresh Install Offline**:
   - Delete the app from the simulator while offline and launch it again.
   - With no cache and no internet, the dashboard displays `"Unable to load courses. Please check your internet connection."` with a **Retry** button.
6. **Restore Connectivity**:
   - Turn Wi-Fi back on and tap **Retry** (or pull-to-refresh) to sync fresh data.

---

## Tests

The project includes an automated test suite in `LearningDashboardTests/CourseProgressTests.swift`:

- `testProgressWithZeroLessonsReturnsZero`: Validates progress edge case with 0 lessons.
- `testProgressWithFourLessonsTwoCompletedReturnsFiftyPercent`: Validates 50% derived calculation.
- `testProgressWithAllLessonsCompletedReturnsOneHundredPercent`: Validates 100% completion calculation.
- `testProgressWithNoLessonsCompletedReturnsZeroPercent`: Validates 0% unstarted calculation.
- `testLoginValidationEmptyEmail`: Verifies rejection of empty email input.
- `testLoginValidationInvalidEmail`: Verifies regex rejection of malformed email strings.
- `testLoginValidationShortPassword`: Verifies rejection of passwords shorter than 6 characters.
- `testLoginValidationSuccess`: Verifies valid credentials pass validation.
- `testLoginPasswordVisibilityToggle`: Verifies hide/show password state toggle.
- `testCourseDetailViewModelToggleLessonUpdatesProgress`: Verifies SwiftData lesson completion persistence and dynamic recalculation.
- `testDashboardLoadsCachedDataWhenOffline`: Verifies cache retention during connection failure.
- `testDashboardFreshInstallOfflineShowsErrorState`: Verifies error state presentation when offline with no cache.
- `testAPIClientRealHTTPFetchAndMapping`: Verifies live `URLSession` HTTP request, JSON decoding, and domain model mapping.

Run tests in Xcode using `Cmd + U` or via terminal:
```bash
xcodebuild test -project LearningDashboard.xcodeproj -scheme LearningDashboard -destination "platform=iOS Simulator,name=iPhone 16"
```

---

## Demo Video

🎥 [Watch the iOS Technical Assignment Demo](https://github.com/aayush-gandhi-ios/Intellipaat-iOS-Assignment/releases/download/v1.0/Assignment_Demo.MP4)
