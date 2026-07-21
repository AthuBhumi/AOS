import SwiftUI
import Models

public struct QuizView: View {
    @Bindable private var viewModel: RoadmapViewModel
    let node: RoadmapNode
    private let userId: UUID
    @Environment(\.dismiss) private var dismiss
    @State private var activeTab = 0 // 0: Notes, 1: Quiz
    @State private var selectedOptionIndex: Int?
    @State private var errorMessage: String?
    @State private var showSuccess = false
    
    public init(viewModel: RoadmapViewModel, node: RoadmapNode, userId: UUID) {
        self.viewModel = viewModel
        self.node = node
        self.userId = userId
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Drag handle
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)
                
                // Title
                Text(node.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                // Tabs Selector
                Picker("", selection: $activeTab) {
                    Text("Study Notes").tag(0)
                    Text("Lesson Quiz").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                
                if activeTab == 0 {
                    // Notes tab
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(node.studyNotes)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .lineSpacing(6)
                        }
                        .padding(20)
                        .background(Color(hex: "#1C1C1E").opacity(0.7))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                    }
                } else {
                    // Quiz tab
                    VStack(alignment: .leading, spacing: 16) {
                        Text(node.quizQuestion)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.bottom, 8)
                        
                        // Option Radio Rows
                        ForEach(0..<node.quizOptions.count, id: \.self) { idx in
                            let option = node.quizOptions[idx]
                            let isSelected = selectedOptionIndex == idx
                            
                            Button(action: { selectedOptionIndex = idx }) {
                                HStack {
                                    Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                                        .foregroundColor(isSelected ? Color(hex: "#0A84FF") : .gray)
                                    Text(option)
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white.opacity(isSelected ? 0.15 : 0.05))
                                .cornerRadius(12)
                            }
                        }
                        
                        // Warning banner
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "#FF453A"))
                                .padding(.top, 4)
                        }
                        
                        if showSuccess {
                            Text("Correct! Unlocked next lesson and awarded +\(node.xpReward) XP.")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "#30D158"))
                                .padding(.top, 4)
                        }
                        
                        Button(action: { submitQuiz() }) {
                            Text("Submit Answer")
                                .font(.system(size: 17, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedOptionIndex != nil ? Color(hex: "#0A84FF") : Color.gray.opacity(0.2))
                                .foregroundColor(selectedOptionIndex != nil ? .black : .gray)
                                .cornerRadius(12)
                        }
                        .disabled(selectedOptionIndex == nil || showSuccess)
                        .padding(.top, 8)
                    }
                    .padding(20)
                    .background(Color(hex: "#1C1C1E").opacity(0.7))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
        }
    }
    
    private func submitQuiz() {
        guard let selected = selectedOptionIndex else { return }
        errorMessage = nil
        
        viewModel.submitQuizAnswer(nodeId: node.id, selectedIndex: selected, forUser: userId) { result in
            switch result {
            case .failure(let error):
                errorMessage = error.localizedDescription
            case .success:
                showSuccess = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
    }
}
