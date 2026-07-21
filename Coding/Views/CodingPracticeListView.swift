import SwiftUI
import Models

public struct CodingPracticeListView: View {
    @State private var viewModel: CodingPracticeViewModel
    private let userId: UUID
    @State private var selectedDifficulty = "Easy"
    
    public init(viewModel: CodingPracticeViewModel, userId: UUID) {
        _viewModel = State(initialValue: viewModel)
        self.userId = userId
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
            case .failure(let error):
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 44))
                        .foregroundColor(Color(hex: "#FF453A"))
                    Text(error)
                        .foregroundColor(.white)
                    Button("Retry") { viewModel.loadProblems() }
                        .foregroundColor(Color(hex: "#0A84FF"))
                }
                
            case .loaded(let problems), .compiling, .compiled:
                VStack(spacing: 16) {
                    // Header Filter Picker
                    Picker("", selection: $selectedDifficulty) {
                        Text("Easy").tag("Easy")
                        Text("Medium").tag("Medium")
                        Text("Hard").tag("Hard")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    let filtered = problems.filter { $0.difficulty == selectedDifficulty }
                    
                    if filtered.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "code.square")
                                .font(.system(size: 44))
                                .foregroundColor(.gray)
                            Text("No challenges unlocked.")
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 80)
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(filtered) { problem in
                                    NavigationLink(destination: CodeEditorView(viewModel: viewModel, userId: userId).onAppear {
                                        viewModel.selectProblem(problem)
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(problem.title)
                                                    .font(.system(size: 17, weight: .bold))
                                                    .foregroundColor(.white)
                                                
                                                Text("Rewards +\(problem.xpReward) XP")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(Color(hex: "#BF5AF2"))
                                            }
                                            Spacer()
                                            
                                            if problem.isCompleted {
                                                Image(systemName: "checkmark.seal.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(Color(hex: "#30D158"))
                                            } else {
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .padding()
                                        .background(Color(hex: "#1C1C1E").opacity(0.7))
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadProblems()
        }
        .navigationTitle("Sandbox Challenges")
        .navigationBarTitleDisplayMode(.inline)
    }
}
extension CodingProblem: Identifiable {}
