import SwiftUI

public struct ProfileSetupView: View {
    @State private var viewModel: ProfileSetupViewModel
    
    public init(viewModel: ProfileSetupViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Avatar representation circle
                ZStack {
                    Circle()
                        .fill(Color(hex: "#1C1C1E"))
                        .frame(width: 96, height: 96)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 8) {
                    Text("Configure Profile")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Choose how your virtual board advisors address you.")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                // Form Card
                VStack(spacing: 16) {
                    TextField("", text: $viewModel.displayName, prompt: Text("Display Name").foregroundColor(.gray))
                        .autocorrectionDisabled()
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
                    
                    Button(action: { viewModel.saveProfile() }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Complete Setup")
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
        .navigationBarHidden(true)
    }
}
