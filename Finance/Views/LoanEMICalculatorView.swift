import SwiftUI
import Models

public struct LoanEMICalculatorView: View {
    @Bindable private var viewModel: AdvancedFinanceViewModel
    private let userId: UUID
    
    @State private var principal: Double = 50000.0
    @State private var interestRate: Double = 8.5
    @State private var tenureMonths: Double = 120.0
    @State private var loanName = ""
    @State private var successAlert = false
    
    public init(viewModel: AdvancedFinanceViewModel, userId: UUID) {
        self.viewModel = viewModel
        self.userId = userId
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Result Summary Card
                    let emi = viewModel.calculateEMI(principal: principal, annualRate: interestRate, tenureMonths: Int(tenureMonths))
                    let totalPayable = emi * tenureMonths
                    let totalInterest = totalPayable - principal
                    
                    emiResultCard(emi: emi, totalInterest: totalInterest, totalPayable: totalPayable)
                    
                    // Sliders Card
                    slidersInputsCard()
                    
                    // Save to Database Card
                    saveLoanCard(emi: emi)
                }
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("EMI Calculator")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func emiResultCard(emi: Double, totalInterest: Double, totalPayable: Double) -> some View {
        VStack(spacing: 16) {
            Text("ESTIMATED MONTHLY PAYMENT")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
                .tracking(1.0)
            
            Text(String(format: "$%.2f/mo", emi))
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(Color(hex: "#0A84FF"))
            
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text(String(format: "$%.0f", totalInterest))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Text("Total Interest")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 4) {
                    Text(String(format: "$%.0f", totalPayable))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Text("Total Payback")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#1C1C1E"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private func slidersInputsCard() -> some View {
        VStack(spacing: 20) {
            // Principal
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Loan Principal:")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(String(format: "$%.0f", principal))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }
                Slider(value: $principal, in: 5000.0...500000.0, step: 5000.0)
                    .accentColor(Color(hex: "#0A84FF"))
            }
            
            // Interest Rate
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Interest Rate:")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(String(format: "%.1f%%", interestRate))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }
                Slider(value: $interestRate, in: 2.0...18.0, step: 0.1)
                    .accentColor(Color(hex: "#0A84FF"))
            }
            
            // Tenure
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Tenure (Months):")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(String(format: "%.0f mos", tenureMonths))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }
                Slider(value: $tenureMonths, in: 12.0...360.0, step: 12.0)
                    .accentColor(Color(hex: "#0A84FF"))
            }
        }
        .padding(20)
        .background(Color(hex: "#1C1C1E").opacity(0.7))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    private func saveLoanCard(emi: Double) -> some View {
        VStack(spacing: 12) {
            TextField("", text: $loanName, prompt: Text("Loan Name (e.g. Car Loan)").foregroundColor(.gray))
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .foregroundColor(.white)
            
            if successAlert {
                Text("Loan saved to ledger successfully!")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#30D158"))
            }
            
            Button("Save Loan to Tracker") {
                let loan = DebtLoan(userId: userId, loanName: loanName, principal: principal, interestRate: interestRate, tenureMonths: Int(tenureMonths), remainingBalance: principal)
                try? viewModel.saveLoan(loan)
                
                // Automatically log Fixed Expense transaction representation of EMI
                viewModel.addTransaction(descr: "\(loanName) EMI", amount: emi, category: "Fixed Expense", notes: "Auto calculated loan EMI", forUser: userId) { _ in }
                
                loanName = ""
                successAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    successAlert = false
                }
                viewModel.loadAllData(forUser: userId)
            }
            .font(.system(size: 17, weight: .bold))
            .frame(maxWidth: .infinity)
            .padding()
            .background(!loanName.isEmpty ? Color(hex: "#30D158") : Color.gray.opacity(0.2))
            .foregroundColor(!loanName.isEmpty ? .black : .gray)
            .cornerRadius(12)
            .disabled(loanName.isEmpty)
        }
        .padding()
        .background(Color(hex: "#1C1C1E"))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}
