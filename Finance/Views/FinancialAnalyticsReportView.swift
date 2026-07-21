import SwiftUI
import Models

public struct FinancialAnalyticsReportView: View {
    @Bindable private var viewModel: AdvancedFinanceViewModel
    private let userId: UUID
    
    @State private var searchText = ""
    @State private var categoryFilter = "All"
    @State private var showExportSheet = false
    @State private var exportCSVText = ""
    
    @State private var descr = ""
    @State private var amount = ""
    @State private var category = "Variable Expense"
    @State private var notes = ""
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
                // Quick log transaction form
                transactionQuickForm()
                
                // Exporter and Filter controls
                HStack(spacing: 12) {
                    TextField("", text: $searchText, prompt: Text("Search ledger...").foregroundColor(.gray))
                        .padding(10)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                    
                    Button(action: { triggerExport() }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color(hex: "#0A84FF"))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
                
                // Segmented picker filters
                Picker("", selection: $categoryFilter) {
                    Text("All").tag("All")
                    Text("Incomes").tag("Incomes")
                    Text("Expenses").tag("Expenses")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                
                // Transactions List
                let filteredTx = applyFilters()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(filteredTx) { tx in
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(tx.descr)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("\(tx.category) • \(tx.notes)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                
                                Text(String(format: "%@$%.0f", tx.category.contains("Expense") ? "-" : "+", tx.amount))
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(tx.category.contains("Expense") ? .white : Color(hex: "#30D158"))
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
        .navigationTitle("Analytics Report")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showExportSheet) {
            exportPreviewSheet()
        }
    }
    
    private func transactionQuickForm() -> some View {
        VStack(spacing: 12) {
            TextField("", text: $descr, prompt: Text("Item description (e.g. Salary, AWS)").foregroundColor(.gray))
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                TextField("", text: $amount, prompt: Text("Amount ($)").foregroundColor(.gray))
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                
                Picker("", selection: $category) {
                    Text("Salary").tag("Salary")
                    Text("Income").tag("Income")
                    Text("Fixed Exp").tag("Fixed Expense")
                    Text("Variable Exp").tag("Variable Expense")
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal, 8)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
            
            TextField("", text: $notes, prompt: Text("Add memo notes... (Optional)").foregroundColor(.gray))
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .foregroundColor(.white)
            
            if successAlert {
                Text("Transaction recorded successfully!")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#30D158"))
            }
            
            Button("Record Transaction") {
                if let val = Double(amount) {
                    viewModel.addTransaction(descr: descr, amount: val, category: category, notes: notes, forUser: userId) { success in
                        if success {
                            descr = ""
                            amount = ""
                            notes = ""
                            successAlert = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
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
    }
    
    private func applyFilters() -> [AdvancedTransaction] {
        var list = viewModel.transactions
        
        // Search
        if !searchText.isEmpty {
            list = list.filter { $0.descr.lowercased().contains(searchText.lowercased()) }
        }
        
        // Category Filter
        if categoryFilter == "Incomes" {
            list = list.filter { $0.category == "Salary" || $0.category == "Income" }
        } else if categoryFilter == "Expenses" {
            list = list.filter { $0.category.contains("Expense") }
        }
        
        return list
    }
    
    private func triggerExport() {
        exportCSVText = viewModel.buildCSVText()
        showExportSheet = true
    }
    
    private func exportPreviewSheet() -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)
                
                Text("Export CSV Preview")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                ScrollView {
                    Text(exportCSVText)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                Button("Share / Copy CSV") {
                    UIPasteboard.general.string = exportCSVText
                    showExportSheet = false
                }
                .font(.system(size: 17, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#30D158"))
                .foregroundColor(.black)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }
}
extension AdvancedTransaction: Identifiable {}
