import SwiftUI
import Models

public struct TypingTrainerView: View {
    @State private var viewModel: TypingTrainerViewModel
    private let userId: UUID
    private let activeStage: Int
    @State private var textInput = ""
    
    public init(viewModel: TypingTrainerViewModel, userId: UUID, activeStage: Int) {
        _viewModel = State(initialValue: viewModel)
        self.userId = userId
        self.activeStage = activeStage
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                switch viewModel.state {
                case .idle:
                    VStack(spacing: 20) {
                        Image(systemName: "keyboard")
                            .font(.system(size: 64))
                            .foregroundColor(Color(hex: "#0A84FF"))
                        
                        Text("Typing Speed Trainer")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Verify your Java syntax coding typing speeds. Complete target code phrases with >85% accuracy and >40 WPM to level up your stats.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        Button(action: {
                            viewModel.loadPhrase(forStage: activeStage)
                            viewModel.startSession()
                        }) {
                            Text("Start Typing Drill")
                                .font(.system(size: 17, weight: .bold))
                                .padding()
                                .background(Color(hex: "#0A84FF"))
                                .foregroundColor(.black)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.top, 40)
                    
                case .active:
                    VStack(spacing: 24) {
                        // Live Metrics indicators
                        HStack(spacing: 32) {
                            metricLabel(title: "WPM", value: String(format: "%.0f", viewModel.currentWPM))
                            metricLabel(title: "Accuracy", value: String(format: "%.0f%%", viewModel.currentAccuracy))
                        }
                        
                        // Highlighted Target Character Box
                        highlightedTargetText()
                            .padding(20)
                            .background(Color(hex: "#1C1C1E"))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        
                        // Hidden/Ghost input field
                        TextField("", text: $textInput, prompt: Text("Type the phrase above...").foregroundColor(.gray))
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .onChange(of: textInput) {
                                viewModel.updateTypedText(textInput, userId: userId)
                            }
                        
                        Button("Abort Drill") {
                            textInput = ""
                            viewModel.resetSession()
                        }
                        .foregroundColor(Color(hex: "#FF453A"))
                    }
                    .padding(.horizontal, 20)
                    
                case .complete(let session):
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 64))
                            .foregroundColor(Color(hex: "#30D158"))
                        
                        Text("Drill Completed!")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        // Results Card
                        VStack(spacing: 12) {
                            HStack {
                                Text("Average WPM:")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(String(format: "%.1f", session.wpm))
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Text("Accuracy:")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(String(format: "%.1f%%", session.accuracy))
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Text("Time Spent:")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(String(format: "%.1fs", session.timeSpentSeconds))
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(20)
                        .background(Color(hex: "#1C1C1E"))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        
                        Button(action: {
                            textInput = ""
                            viewModel.resetSession()
                        }) {
                            Text("Try Another Drill")
                                .font(.system(size: 17, weight: .bold))
                                .padding()
                                .background(Color(hex: "#0A84FF"))
                                .foregroundColor(.black)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.top, 40)
                    
                case .failure(let error):
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 44))
                            .foregroundColor(Color(hex: "#FF453A"))
                        Text(error)
                            .foregroundColor(.white)
                        Button("Retry") { viewModel.resetSession() }
                            .foregroundColor(Color(hex: "#0A84FF"))
                    }
                }
                Spacer()
            }
        }
        .navigationTitle("Typing Speed Trainer")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func metricLabel(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
    }
    
    private func highlightedTargetText() -> some View {
        let targetChars = Array(viewModel.targetPhrase)
        let typedChars = Array(viewModel.typedPhrase)
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(0..<targetChars.count, id: \.self) { i in
                    let char = String(targetChars[i])
                    var color: Color = .gray
                    
                    if i < typedChars.count {
                        color = (targetChars[i] == typedChars[i]) ? Color(hex: "#30D158") : Color(hex: "#FF453A")
                    } else if i == typedChars.count {
                        color = .white
                    }
                    
                    Text(char)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(color)
                        .background(i == typedChars.count ? Color.white.opacity(0.2) : Color.clear)
                }
            }
        }
    }
}
