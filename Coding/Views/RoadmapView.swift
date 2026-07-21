import SwiftUI
import Models

public struct RoadmapView: View {
    @State private var viewModel: RoadmapViewModel
    private let userId: UUID
    
    public init(viewModel: RoadmapViewModel, userId: UUID) {
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
                    Button("Retry") { viewModel.loadRoadmap() }
                        .foregroundColor(Color(hex: "#0A84FF"))
                }
                
            case .loaded(let nodes):
                ScrollView {
                    VStack(spacing: 24) {
                        // Progress Overview Header Card
                        progressHeaderCard()
                        
                        // Timeline Tree Nodes
                        VStack(spacing: 0) {
                            ForEach(nodes) { node in
                                HStack(alignment: .top) {
                                    // Vertical Node Connector Line
                                    VStack {
                                        Circle()
                                            .fill(nodeColor(for: node))
                                            .frame(width: 16, height: 16)
                                        
                                        if node != nodes.last {
                                            Rectangle()
                                                .fill(Color.white.opacity(0.15))
                                                .frame(width: 2, height: 80)
                                        }
                                    }
                                    
                                    // Node Content Card
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(node.title)
                                            .font(.system(size: 17, weight: .bold))
                                            .foregroundColor(node.isLocked ? .gray : .white)
                                        
                                        Text(node.topicDescription)
                                            .font(.system(size: 13))
                                            .foregroundColor(.gray)
                                            .lineLimit(2)
                                        
                                        if !node.isLocked && !node.isCompleted {
                                            Button(action: {
                                                viewModel.selectedNodeForQuiz = node
                                            }) {
                                                Text("Start Lesson Quiz")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(Color(hex: "#0A84FF"))
                                                    .foregroundColor(.black)
                                                    .cornerRadius(6)
                                            }
                                            .padding(.top, 4)
                                        } else if node.isCompleted {
                                            Label("Completed", systemImage: "checkmark.seal.fill")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(Color(hex: "#30D158"))
                                                .padding(.top, 4)
                                        } else {
                                            Label("Locked", systemImage: "lock.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                                .padding(.top, 4)
                                        }
                                    }
                                    .padding(.leading, 12)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.top, 16)
                }
            }
        }
        .onAppear {
            viewModel.loadRoadmap()
        }
        .sheet(item: Bindable(viewModel).selectedNodeForQuiz) { node in
            QuizView(viewModel: viewModel, node: node, userId: userId)
        }
        .navigationTitle("Java Academy")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func progressHeaderCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("JAVA MASTER CURRICULUM")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.gray)
                .tracking(1.0)
            
            HStack {
                Text("\(Int(viewModel.completionPercentage))% Completed")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("Study Concurrently")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            ProgressView(value: viewModel.completionPercentage / 100.0)
                .accentColor(Color(hex: "#BF5AF2"))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
        }
        .padding(20)
        .background(Color(hex: "#1C1C1E").opacity(0.7))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    private func nodeColor(for node: RoadmapNode) -> Color {
        if node.isCompleted {
            return Color(hex: "#30D158")
        } else if !node.isLocked {
            return Color(hex: "#0A84FF")
        } else {
            return Color.gray.opacity(0.4)
        }
    }
}
extension RoadmapNode: Identifiable {}
