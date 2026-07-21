import SwiftUI

public struct EditProfileView: View {
    @Bindable private var viewModel: ProfileViewModel
    private let userId: UUID
    @Environment(\.dismiss) private var dismiss
    
    public init(viewModel: ProfileViewModel, userId: UUID) {
        self.viewModel = viewModel
        self.userId = userId
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Drag handle
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)
                
                Text("Edit Profile Details")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 12)
                
                // Form Card
                VStack(spacing: 16) {
                    TextField("", text: $viewModel.updatedDisplayName, prompt: Text("Display Name").foregroundColor(.gray))
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    if case .failure(let error) = viewModel.state {
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#FF453A"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Button(action: {
                        viewModel.updateProfileName(for: userId) { success in
                            if success {
                                dismiss()
                            }
                        }
                    }) {
                        HStack {
                            if viewModel.isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Save Changes")
                                    .font(.system(size: 17, weight: .bold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#0A84FF"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isSaving)
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
