import SwiftUI

public struct SignupView: View {
    @State private var viewModel: SignupViewModel
    
    public init(viewModel: SignupViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 40)
                        
                        Text("Enter your credentials to register.")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    
                    // Forms Card
                    VStack(spacing: 16) {
                        // Name Field
                        TextField("", text: $viewModel.displayName, prompt: Text("Display Name").foregroundColor(.gray))
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                        
                        // Email Field
                        TextField("", text: $viewModel.email, prompt: Text("Email Address").foregroundColor(.gray))
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                        
                        // Password Field
                        SecureField("", text: $viewModel.password, prompt: Text("Password").foregroundColor(.gray))
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                        
                        // Action feedback notifications
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "#FF453A"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        if let success = viewModel.successMessage {
                            Text(success)
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "#30D158"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Submit Button
                        Button(action: { viewModel.signup() }) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Register")
                                        .font(.system(size: 17, weight: .bold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#0A84FF"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.isLoading)
                    }
                    .padding(24)
                    .background(Color(hex: "#1C1C1E").opacity(0.7))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // Back to login redirection
                    Button(action: { viewModel.goBackToLogin() }) {
                        Text("Already have an account? Sign In")
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "#0A84FF"))
                    }
                    .padding(.top, 16)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
