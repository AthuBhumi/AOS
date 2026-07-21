import SwiftUI
import Models

public struct CodeEditorView: View {
    @Bindable private var viewModel: CodingPracticeViewModel
    private let userId: UUID
    @State private var consoleOutput = "Terminal active. Input code and tap Run."
    @State private var showNotes = false
    
    public init(viewModel: CodingPracticeViewModel, userId: UUID) {
        self.viewModel = viewModel
        self.userId = userId
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if let problem = viewModel.selectedProblem {
                VStack(spacing: 0) {
                    // Task Details Card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(problem.title)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Text(problem.difficulty)
                                .font(.system(size: 12, weight: .semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(difficultyColor(problem.difficulty).opacity(0.2))
                                .foregroundColor(difficultyColor(problem.difficulty))
                                .cornerRadius(6)
                        }
                        
                        Text(problem.problemDescription)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .lineLimit(3)
                    }
                    .padding(16)
                    .background(Color(hex: "#1C1C1E"))
                    
                    // Code Input Editor Panel
                    TextEditor(text: $viewModel.codeBuffer)
                        .font(.system(.body, design: .monospaced))
                        .padding(8)
                        .background(Color(hex: "#000000"))
                        .foregroundColor(Color(hex: "#30D158"))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    // Terminal Panel Console
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("CONSOLE OUTPUT")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.gray)
                            Spacer()
                            
                            // Status bar
                            if case .compiling = viewModel.state {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                        }
                        
                        ScrollView {
                            Text(consoleOutput)
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 4)
                        }
                        .frame(height: 120)
                    }
                    .padding(16)
                    .background(Color(hex: "#1C1C1E"))
                    
                    // Action controls bar
                    HStack(spacing: 16) {
                        Button(action: { showNotes = true }) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        Button(action: { runCode() }) {
                            Text("Compile & Run")
                                .font(.system(size: 17, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "#0A84FF"))
                                .foregroundColor(.black)
                                .cornerRadius(12)
                        }
                        .disabled(viewModel.state == .compiling)
                    }
                    .padding(16)
                    .background(Color(hex: "#1C1C1E"))
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showNotes) {
            if let problem = viewModel.selectedProblem {
                notesView(problem: problem)
            }
        }
    }
    
    private func difficultyColor(_ dif: String) -> Color {
        switch dif {
        case "Easy": return Color(hex: "#30D158")
        case "Medium": return Color(hex: "#FFD60A")
        default: return Color(hex: "#FF453A")
        }
    }
    
    private func runCode() {
        consoleOutput = "Compiling source dependencies..."
        viewModel.compileAndRun(forUser: userId) { result in
            switch result {
            case .failure(let error):
                consoleOutput = "Network Error: \(error.localizedDescription)"
            case .success(let dto):
                if dto.status == "SUCCESS" {
                    consoleOutput = "SUCCESS\nExecution Time: \(dto.executionTimeMs)ms\n\nStdout:\n\(dto.stdout)"
                } else if dto.status == "COMPILE_ERROR" {
                    consoleOutput = "COMPILE ERROR\n\nStderr:\n\(dto.stderr)"
                } else {
                    consoleOutput = "RUNTIME ERROR\n\nStderr:\n\(dto.stderr)"
                }
            }
        }
    }
    
    private func notesView(problem: CodingProblem) -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)
                Text(problem.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                ScrollView {
                    Text(problem.problemDescription)
                        .foregroundColor(.white)
                        .lineSpacing(6)
                        .padding(20)
                }
                Spacer()
            }
        }
    }
}
extension CompileResponseDTO: Identifiable {
    public var id: String { status + stdout }
}
