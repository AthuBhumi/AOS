import SwiftUI
import Models

public struct CBTReframingView: View {
    @Bindable private var viewModel: JournalViewModel
    let entry: JournalEntry
    private let userId: UUID
    let onComplete: () -> Void
    @State private var reframeText = ""
    @State private var showSuccess = false
    
    public init(viewModel: JournalViewModel, entry: JournalEntry, userId: UUID, onComplete: @escaping () -> Void) {
        self.viewModel = viewModel
        self.entry = entry
        self.userId = userId
        self.onComplete = onComplete
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)
                
                // Alert Header
                VStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 44))
                        .foregroundColor(Color(hex: "#FFD60A"))
                    
                    Text("CBT Cognitive Reframing")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("We detected **\(entry.detectedDistortion ?? "Distortion")** in your entry. Let's rewrite this statement objectively.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                // Original Text Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("YOUR ORIGINAL LOG:")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                    Text("\"\(entry.content)\"")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .italic()
                }
                .padding()
                .background(Color(hex: "#FFD60A").opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#FFD60A").opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                
                // Input reframe Box
                VStack(alignment: .leading, spacing: 12) {
                    Text("WRITE AN OBJECTIVE REFRAME:")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                    
                    TextEditor(text: $reframeText)
                        .frame(height: 120)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    if showSuccess {
                        Text("Reframe complete! +40 XP awarded.")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#30D158"))
                    }
                    
                    Button("Submit Reframe") {
                        viewModel.submitReframing(entry: entry, reframeText: reframeText, forUser: userId)
                        showSuccess = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            onComplete()
                        }
                    }
                    .font(.system(size: 17, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(!reframeText.isEmpty ? Color(hex: "#30D158") : Color.gray.opacity(0.2))
                    .foregroundColor(!reframeText.isEmpty ? .black : .gray)
                    .cornerRadius(12)
                    .disabled(reframeText.isEmpty || showSuccess)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}
