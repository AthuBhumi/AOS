import SwiftUI
import Models

public struct BudgetPlannerView: View {
    @Bindable private var viewModel: AdvancedFinanceViewModel
    private let userId: UUID
    
    @State private var category = "Variable Expense"
    @State private var monthlyLimit = ""
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
                // Add/Update budget limit form
                VStack(spacing: 12) {
                    Picker("", selection: $category) {
                        Text("Variable Expense").tag("Variable Expense")
                        Text("Fixed Expense").tag("Fixed Expense")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    TextField("", text: $monthlyLimit, prompt: Text("Monthly Limit ($)").foregroundColor(.gray))
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    if successAlert {
                        Text("Budget limit updated successfully!")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#30D158"))
                    }
                    
                    Button("Save Budget Limit") {
                        if let limit = Double(monthlyLimit) {
                            let budget = BudgetLimit(userId: userId, category: category, monthlyLimit: limit)
                            try? viewModel.saveBudget(budget)
                            monthlyLimit = ""
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
                    .background(!monthlyLimit.isEmpty ? Color(hex: "#0A84FF") : Color.gray.opacity(0.2))
                    .foregroundColor(!monthlyLimit.isEmpty ? .black : .gray)
                    .cornerRadius(12)
                    .disabled(monthlyLimit.isEmpty)
                }
                .padding()
                .background(Color(hex: "#1C1C1E"))
                .cornerRadius(16)
                .padding(.horizontal, 20)
                
                // Existing budgets listing
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.budgets) { budget in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(budget.category.uppercased())
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(hex: "#0A84FF"))
                                
                                HStack {
                                    Text("Monthly Limit:")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(String(format: "$%.0f", budget.monthlyLimit))
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                }
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
        .navigationTitle("Budget Planner")
        .navigationBarTitleDisplayMode(.inline)
    }
}
extension BudgetLimit: Identifiable {}
