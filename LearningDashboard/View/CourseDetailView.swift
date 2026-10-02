//
//  CourseDetailView.swift
//  LearningDashboard
//
//  Created by Aayush Gandhi on 01/10/26.
//

import SwiftUI

struct CourseDetailView: View {
    @State var viewModel = CourseDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                progressCard
                
                lessonsSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .opacity(viewModel.isContentVisible ? 1 : 0)
            .animation(.easeIn(duration: 0.3), value: viewModel.isContentVisible)
        }
        .navigationTitle(viewModel.course.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadCourse() }
        .animation(.easeInOut(duration: 0.25), value: viewModel.progress)
    }

    var progressCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Overall Progress")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.progressText)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("\(viewModel.course.completedLessonCount)/\(viewModel.course.lessonCount)")
                    .font(.subheadline.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.12))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }

            ProgressView(value: viewModel.progressRatio)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding(.vertical, 4)

            Text(viewModel.lessonsSummaryText)
                .font(.caption)
                .foregroundColor(.secondary)

            if let errorMsg = viewModel.errorMessage {
                Text(errorMsg)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(18)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    var lessonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lessons")
                .font(.headline)
                .foregroundColor(.primary)

            LazyVStack(spacing: 10) {
                ForEach(viewModel.course.lessons) { lesson in
                    Button {
                        HapticFeedback.light()
                        Task {
                            await viewModel.toggleLessonCompletion(lessonId: lesson.id)
                        }
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: lesson.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 22))
                                .foregroundColor(lesson.isCompleted ? .green : .secondary)

                            Text(lesson.title)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)

                            Spacer()

                            Text(lesson.isCompleted ? "Completed" : "Pending")
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(lesson.isCompleted ? Color.green.opacity(0.12) : Color.secondary.opacity(0.12))
                                .foregroundColor(lesson.isCompleted ? .green : .secondary)
                                .cornerRadius(6)
                        }
                        .padding(14)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

#Preview { CourseDetailView(viewModel: .init()) }
