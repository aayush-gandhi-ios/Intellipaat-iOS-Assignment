//
//  CourseDashboardView.swift
//  LearningDashboard
//
//  Created by Aayush Gandhi on 01/10/26.
//

import SwiftUI

struct CourseDashboardView: View {
    @State var viewModel = CourseDashboardViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                offlineBanner

                switch viewModel.state {
                case .idle, .loading:
                    loadingStateView
                case .empty:
                    emptyStateView
                case .error(let message):
                    errorStateView(message: message)
                case .loaded:
                    coursesListView
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .opacity(viewModel.isContentVisible ? 1 : 0)
            .animation(.easeIn(duration: 0.3), value: viewModel.isContentVisible)
            .navigationDestination(isPresented: $viewModel.shouldNavigateToDetail) {
                CourseDetailView()
            }
        }
        .navigationTitle("Courses")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.loadCourses() }
        .onAppear { viewModel.onAppear() }
        .refreshable { await viewModel.loadCourses() }
        .animation(.easeInOut(duration: 0.25), value: viewModel.state)
    }

    @ViewBuilder
    var offlineBanner: some View {
        if viewModel.isOffline {
            HStack(spacing: 8) {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.orange)

                Text("Offline — Displaying cached courses")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.orange)

                Spacer()
            }
            .padding(10)
            .background(Color.orange.opacity(0.12))
            .cornerRadius(8)
        }
    }

    var loadingStateView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.3)

            Text("Loading courses...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    var emptyStateView: some View {
        VStack(spacing: 14) {
            Image(systemName: "tray.fill")
                .font(.system(size: 44))
                .foregroundColor(.secondary)

            Text("No Courses Available")
                .font(.headline)

            Text("There are currently no courses enrolled.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("Refresh") {
                HapticFeedback.light()
                Task { await viewModel.loadCourses() }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    func errorStateView(message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundColor(.red)

            Text("Unable to Load Courses")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Button {
                HapticFeedback.medium()
                Task { await viewModel.loadCourses() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    var coursesListView: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.courses) { course in
                courseCard(for: course)
            }
        }
    }

    func courseCard(for course: Course) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(course.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(course.instructor)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("\(course.progress)%")
                    .font(.subheadline.bold())
                    .foregroundColor(.blue)
            }

            ProgressView(value: course.progressRatio)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))

            HStack {
                Label("\(course.lessonCount) lessons", systemImage: "book.closed.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Button {
                    HapticFeedback.light()
                    viewModel.selectCourse(course)
                } label: {
                    HStack(spacing: 4) {
                        Text("Continue")
                            .font(.subheadline.bold())

                        Image(systemName: "chevron.right")
                            .font(.caption.bold())
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

#Preview { CourseDashboardView(viewModel: .init()) }
