import SwiftUI

public struct LoginView: View {
    @State private var viewModel: LoginViewModel
    
    public init(viewModel: LoginViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            // Dark Mode background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Brand logo asset
                Image(systemName: "bolt.shield")
                    .font(.system(size: 64))
                    .foregroundColor(Color(hex: "#0A84FF"))
                    .symbolEffect(.pulse)
                
                VStack(spacing: 8) {
                    Text("ATHARVA OS")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(0.38)
                    
                    Text("Life Operating System")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                
                // Card material wrapper
                VStack(spacing: 16) {
                    // Email Input
                    TextField("", text: $viewModel.email, prompt: Text("Email address").foregroundColor(.gray))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    // Password Input
                    SecureField("", text: $viewModel.password, prompt: Text("Password").foregroundColor(.gray))
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    // Error message banner
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#FF453A"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .transition(.opacity)
                    }
                    
                    // Submit Action Button
                    Button(action: { viewModel.login() }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign In")
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
                
                // Biometrics FaceID Button
                Button(action: { viewModel.loginWithBiometrics() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "faceid")
                            .font(.system(size: 20))
                        Text("Log In with Face ID")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "#0A84FF"))
                }
                .padding(.top, 12)
                
                Spacer()
                
                // Bottom Routes Navigation
                HStack(spacing: 32) {
                    Button("Forgot Password?") {
                        viewModel.navigateToForgotPassword()
                    }
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    
                    Button("Create Account") {
                        viewModel.navigateToSignup()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "#0A84FF"))
                }
                .padding(.bottom, 24)
            }
        }
    }
}

// Color Utility Extension for Hex strings
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 1)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
