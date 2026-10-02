//
//  LoginView.swift
//  LearningDashboard
//
//  Created by Aayush Gandhi on 01/10/26.
//

import SwiftUI

struct LoginView: View {
    @State var viewModel = LoginViewModel()

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ScrollView {
                VStack(spacing: 28) {
                    headerSection
                    
                    credentialsForm
                    
                    actionSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: String.self) { destination in
                if destination == "dashboard" {
                    CourseDashboardView()
                }
            }
        }
    }

    var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 38))
                .foregroundColor(.blue)
                .frame(width: 80, height: 80)
                .background(Color.blue.opacity(0.12))
                .cornerRadius(99)

            Text("Learning Dashboard")
                .font(.title2.bold())
                .foregroundColor(.primary)

            Text("Sign in to continue your learning journey")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    var credentialsForm: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Email")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)

                TextField("name@example.com", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(14)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(10)
                    .onChange(of: viewModel.email) { _, _ in
                        viewModel.clearError()
                    }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)

                HStack {
                    if viewModel.isPasswordVisible {
                        TextField("Enter password", text: $viewModel.password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else { SecureField("Enter password", text: $viewModel.password) }

                    Button { viewModel.togglePasswordVisibility() } label: {
                        Image(systemName: viewModel.isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    }
                    .accessibilityLabel(viewModel.isPasswordVisible ? "Hide password" : "Show password")
                }
                .padding(14)
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(10)
                .onChange(of: viewModel.password) { _, _ in
                    viewModel.clearError()
                }
            }

            if let errorMsg = viewModel.state.errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    
                    Text(errorMsg)
                        .font(.footnote)
                        .foregroundColor(.red)
                    
                    Spacer()
                }
                .padding(12)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    var actionSection: some View {
        VStack(spacing: 14) {
            Button {
                HapticFeedback.medium()
                Task { await viewModel.login() }
            } label: {
                HStack(spacing: 10) {
                    if viewModel.state.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign In")
                            .font(.headline)
                        
                        Image(systemName: "arrow.right")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(viewModel.state.isLoading ? Color.blue.opacity(0.7) : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(viewModel.state.isLoading)

            Text("Demo credentials are pre-filled")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview { LoginView(viewModel: .init()) }
