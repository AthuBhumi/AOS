import SwiftUI
import Models

public struct SavingsGoalsListView: View {
    @Bindable private var viewModel: AdvancedFinanceViewModel
    private let userId: UUID
    
    @State private var goalName = ""
    @State private var targetAmount = ""
    @State private var currentSavings = ""
    @State private var successAlert = false
    
    public init(viewModel: AdvancedFinanceViewModel, userId: UUID) {
        self.viewModel = viewModel
        self.userId = userId
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Add Goal Card
                VStack(spacing: 12) {
                    TextField("", text: $goalName, prompt: Text("Savings Goal Name").foregroundColor(.gray))
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        TextField("", text: $targetAmount, prompt: Text("Target ($)").foregroundColor(.gray))
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                        
                        TextField("", text: $currentSavings, prompt: Text("Saved ($)").foregroundColor(.gray))
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                    }
                    
                    if successAlert {
                        Text("Savings Goal saved successfully!")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#30D158"))
                    }
                    
                    Button("Add Savings Goal") {
                        if let target = Double(targetAmount), let current = Double(currentSavings) {
                            let goal = SavingsGoal(userId: userId, goalName: goalName, targetAmount: target, currentSavings: current)
                            try? viewModel.saveSavingsGoal(goal)
                            goalName = ""
                            targetAmount = ""
                            currentSavings = ""
                            successAlert = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                successAlert = false
                            }
                            viewModel.loadAllData(forUser: userId)
                        }
                    }
                    .font(.system(size: 17, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(!goalName.isEmpty && !targetAmount.isEmpty ? Color(hex: "#0A84FF") : Color.gray.opacity(0.2))
                    .foregroundColor(!goalName.isEmpty && !targetAmount.isEmpty ? .black : .gray)
                    .cornerRadius(12)
                    .disabled(goalName.isEmpty || targetAmount.isEmpty)
                }
                .padding()
                .background(Color(hex: "#1C1C1E"))
                .cornerRadius(16)
                .padding(.horizontal, 20)
                
                // Goals List
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.savingsGoals) { goal in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(goal.goalName)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(String(format: "$%.0f / $%.0f", goal.currentSavings, goal.targetAmount))
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.gray)
                                }
                                
                                let progress = min(1.0, goal.currentSavings / goal.targetAmount)
                                ProgressView(value: progress)
                                    .accentColor(Color(hex: "#30D158"))
                            }
                            .padding()
                            .background(Color(hex: "#1C1C1E").opacity(0.7))
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.top, 16)
        }
        .navigationTitle("Savings Targets")
        .navigationBarTitleDisplayMode(.inline)
    }
}
extension SavingsGoal: Identifiable {}
