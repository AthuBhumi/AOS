import SwiftUI
import Models

public struct GoalListView: View {
    @State private var viewModel: GoalViewModel
    private let userId: UUID
    @State private var showAddSheet = false
    @State private var expandedGoalId: UUID?
    
    public init(viewModel: GoalViewModel, userId: UUID) {
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
                    Button("Retry") { viewModel.loadGoals(forUser: userId) }
                        .foregroundColor(Color(hex: "#0A84FF"))
                }
                
            case .loaded(let goals):
                VStack(spacing: 20) {
                    if goals.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "scope")
                                .font(.system(size: 44))
                                .foregroundColor(.gray)
                            Text("No OKR goals established.")
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 80)
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(goals) { goal in
                                    VStack(alignment: .leading, spacing: 12) {
                                        // Header
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(goal.category.uppercased())
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundColor(categoryColor(goal.category))
                                                Text(goal.title)
                                                    .font(.system(size: 17, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                            Spacer()
                                            
                                            Button(action: {
                                                withAnimation {
                                                    expandedGoalId = (expandedGoalId == goal.id) ? nil : goal.id
                                                }
                                            }) {
                                                Image(systemName: expandedGoalId == goal.id ? "chevron.up" : "chevron.down")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        
                                        // Progress percentage
                                        HStack {
                                            ProgressView(value: goal.progress / 100.0)
                                                .accentColor(categoryColor(goal.category))
                                            Text("\(Int(goal.progress))%")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(.white)
                                                .padding(.leading, 8)
                                        }
                                        
                                        // Expanded Key Results list
                                        if expandedGoalId == goal.id {
                                            VStack(spacing: 10) {
                                                Divider()
                                                    .background(Color.white.opacity(0.1))
                                                
                                                ForEach(goal.keyResults) { kr in
                                                    HStack {
                                                        Button(action: {
                                                            viewModel.toggleKeyResult(goalId: goal.id, keyResultId: kr.id, forUser: userId) { _ in }
                                                        }) {
                                                            Image(systemName: kr.isCompleted ? "checkmark.circle.fill" : "circle")
                                                                .foregroundColor(kr.isCompleted ? Color(hex: "#30D158") : .gray)
                                                        }
                                                        
                                                        Text(kr.title)
                                                            .font(.system(size: 14))
                                                            .foregroundColor(kr.isCompleted ? .gray : .white)
                                                            .strikethrough(kr.isCompleted, color: .gray)
                                                        Spacer()
                                                    }
                                                    .padding(.vertical, 4)
                                                }
                                            }
                                            .transition(.opacity)
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
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadGoals(forUser: userId)
        }
        .navigationTitle("Goal OKRs")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddGoalView(viewModel: viewModel, userId: userId)
        }
    }
    
    private func categoryColor(_ cat: String) -> Color {
        switch cat {
        case "Skill": return Color(hex: "#0A84FF")
        case "Career": return Color(hex: "#BF5AF2")
        default: return Color(hex: "#30D158")
        }
    }
}
extension KeyResult: Identifiable {}
