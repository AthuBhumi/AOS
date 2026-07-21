import SwiftUI
import Models

public struct TransactionLedgerView: View {
    @Bindable private var viewModel: FinanceViewModel
    private let userId: UUID
    
    @State private var descr = ""
    @State private var amount = ""
    @State private var category = "Variable Expense"
    @State private var successAlert = false
    
    public init(viewModel: FinanceViewModel, userId: UUID) {
        self.viewModel = viewModel
        self.userId = userId
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Forms card
                VStack(spacing: 12) {
                    TextField("", text: $descr, prompt: Text("Transaction Description").foregroundColor(.gray))
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    TextField("", text: $amount, prompt: Text("Amount ($)").foregroundColor(.gray))
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    Picker("", selection: $category) {
                        Text("Income").tag("Income")
                        Text("Fixed Exp").tag("Fixed Expense")
                        Text("Variable Exp").tag("Variable Expense")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if successAlert {
                        Text("Transaction logged! +10 XP awarded.")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#30D158"))
                    }
                    
                    Button("Log Transaction") {
                        if let value = Double(amount) {
                            viewModel.addTransaction(descr: descr, amount: value, category: category, forUser: userId) { success in
                                if success {
                                    descr = ""
                                    amount = ""
                                    successAlert = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        successAlert = false
                                    }
                                }
                            }
                        }
                    }
                    .font(.system(size: 17, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(!descr.isEmpty && !amount.isEmpty ? Color(hex: "#0A84FF") : Color.gray.opacity(0.2))
                    .foregroundColor(!descr.isEmpty && !amount.isEmpty ? .black : .gray)
                    .cornerRadius(12)
                    .disabled(descr.isEmpty || amount.isEmpty)
                }
                .padding()
                .background(Color(hex: "#1C1C1E"))
                .cornerRadius(16)
                .padding(.horizontal, 20)
                
                // Ledger history scroll
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.transactions) { tx in
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(tx.descr)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text(tx.category)
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 6) {
                                    Text("\(tx.category == "Income" ? "+" : "-")$\(Int(tx.amount))")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(tx.category == "Income" ? Color(hex: "#30D158") : .white)
                                    
                                    // Runway hazard flag on variable expenses
                                    if viewModel.isRunwayHazard && tx.category == "Variable Expense" {
                                        Text("Runway Hazard")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(Color(hex: "#FF453A"))
                                    }
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
                }
            }
            .padding(.top, 16)
        }
        .navigationTitle("Transaction Ledger")
        .navigationBarTitleDisplayMode(.inline)
    }
}
extension Transaction: Identifiable {}
