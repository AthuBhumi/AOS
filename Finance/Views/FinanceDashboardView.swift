import SwiftUI
import Models

public struct FinanceDashboardView: View {
    @State private var viewModel: FinanceViewModel
    private let userId: UUID
    
    public init(viewModel: FinanceViewModel, userId: UUID) {
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
                    Button("Retry") { viewModel.loadFinanceData(forUser: userId) }
                        .foregroundColor(Color(hex: "#0A84FF"))
                }
                
            case .loaded:
                ScrollView {
                    VStack(spacing: 24) {
                        // Hazard alert banner
                        if viewModel.isRunwayHazard {
                            hazardAlertBanner()
                        }
                        
                        // Runway Dial Gauge card
                        runwayGaugeCard()
                        
                        // Accounts Balance lists
                        accountsBalanceCard()
                        
                        // Ledger navigation button
                        NavigationLink(destination: TransactionLedgerView(viewModel: viewModel, userId: userId)) {
                            Text("Open Transaction Ledger")
                                .font(.system(size: 17, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "#0A84FF"))
                                .foregroundColor(.black)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadFinanceData(forUser: userId)
        }
        .navigationTitle("Capital Runway")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func hazardAlertBanner() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.shield.fill")
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "#FF453A"))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("RUNWAY HAZARD DETECTED")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(hex: "#FF453A"))
                Text("Capital runway is under 6 months. Non-essential expenses have been flagged for cost reduction.")
                    .font(.system(size: 13))
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color(hex: "#FF453A").opacity(0.15))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#FF453A").opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private func runwayGaugeCard() -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 10)
                    .frame(width: 140, height: 140)
                
                // Map runway 0-12 months to progress dial trim
                let trimLimit = min(1.0, viewModel.survivalRunwayMonths / 12.0)
                Circle()
                    .trim(from: 0.0, to: CGFloat(trimLimit))
                    .stroke(viewModel.isRunwayHazard ? Color(hex: "#FF453A") : Color(hex: "#30D158"), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text(String(format: "%.1f", viewModel.survivalRunwayMonths))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Text("Months Runway")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text("$\(Int(viewModel.monthlyBurn))")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    Text("Monthly Burn")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 4) {
                    Text("$\(Int(viewModel.totalCash))")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    Text("Cash Reserves")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#1C1C1E").opacity(0.7))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    private func accountsBalanceCard() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("FINANCIAL ACCOUNTS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.gray)
                .tracking(1.0)
                .padding(.leading, 8)
            
            VStack(spacing: 12) {
                ForEach(viewModel.accounts) { acc in
                    HStack {
                        Image(systemName: acc.type == "Cash" ? "banknote.fill" : "chart.xyaxis.line")
                            .foregroundColor(Color(hex: "#0A84FF"))
                        Text(acc.name)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                        Spacer()
                        Text("$\(Int(acc.balance))")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                    if acc != viewModel.accounts.last {
                        Divider()
                            .background(Color.white.opacity(0.1))
                    }
                }
            }
            .padding(16)
            .background(Color(hex: "#1C1C1E").opacity(0.7))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
    }
}
extension FinancialAccount: Identifiable {}
