import SwiftUI

public struct ForgotPasswordView: View {
    @State private var viewModel: ForgotPasswordViewModel
    
    public init(viewModel: ForgotPasswordViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Handle indicator
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)
                
                VStack(spacing: 8) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 48))
                        .foregroundColor(Color(hex: "#0A84FF"))
                    
                    Text("Recover Password")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Enter your email address to receive reset details.")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.top, 24)
                
                // Form Card
                VStack(spacing: 16) {
                    TextField("", text: $viewModel.email, prompt: Text("Email Address").foregroundColor(.gray))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
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
                    
                    Button(action: { viewModel.requestPasswordReset() }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Send Reset Link")
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
                
                Spacer()
            }
        }
    }
}
