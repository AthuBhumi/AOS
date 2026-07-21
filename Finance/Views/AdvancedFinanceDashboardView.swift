import SwiftUI
import Models

public struct AdvancedFinanceDashboardView: View {
    @State private var viewModel: AdvancedFinanceViewModel
    @State private var insightsVM = AIFinanceInsightsViewModel()
    private let userId: UUID
    
    public init(viewModel: AdvancedFinanceViewModel, userId: UUID) {
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
                    Button("Retry") { viewModel.loadAllData(forUser: userId) }
                        .foregroundColor(Color(hex: "#0A84FF"))
                }
                
            case .loaded:
                ScrollView {
                    VStack(spacing: 24) {
                        // Net Worth Card
                        netWorthCard()
                        
                        // Runway Dial Gauge Card
                        runwayGaugeCard()
                        
                        // Sub-Trackers Grid Navigation Menu
                        subTrackersMenu()
                        
                        // AI Financial Insights segment
                        aiInsightsSegment()
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            viewModel.loadAllData(forUser: userId)
        }
        .navigationTitle("Capital Engine")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func netWorthCard() -> some View {
        let totalNetWorth = viewModel.totalCapitalReserves + viewModel.investmentPortfolioValue
        
        return VStack(spacing: 6) {
            Text("NET WORTH VALUE")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
                .tracking(1.0)
            
            Text(String(format: "$%.2f", totalNetWorth))
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                Text(String(format: "Cash: $%.0f", viewModel.totalCapitalReserves))
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                
                Circle()
                    .fill(Color.gray)
                    .frame(width: 4, height: 4)
                
                Text(String(format: "Assets: $%.0f", viewModel.investmentPortfolioValue))
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            .padding(.top, 4)
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
    
    private func runwayGaugeCard() -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 10)
                    .frame(width: 130, height: 130)
                
                let trimLimit = min(1.0, viewModel.survivalRunwayMonths / 12.0)
                Circle()
                    .trim(from: 0.0, to: CGFloat(trimLimit))
                    .stroke(viewModel.survivalRunwayMonths < 6.0 ? Color(hex: "#FF453A") : Color(hex: "#30D158"), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 130, height: 130)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text(String(format: "%.1f", viewModel.survivalRunwayMonths))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Text("Months Runway")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }
            
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text(String(format: "$%.0f", viewModel.monthlyBurn))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Monthly Burn")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 4) {
                    Text(String(format: "$%.0f", viewModel.totalCapitalReserves))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Cash Reserves")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#1C1C1E").opacity(0.7))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    private func subTrackersMenu() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FINANCIAL CONTROL BOARD")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
                .tracking(1.0)
                .padding(.leading, 8)
            
            VStack(spacing: 12) {
                NavigationLink(destination: SavingsGoalsListView(viewModel: viewModel, userId: userId)) {
                    menuItemRow(title: "Savings Goals", desc: "Goal progression targets", icon: "scope")
                }
                
                NavigationLink(destination: InvestmentsPortfolioView(viewModel: viewModel, userId: userId)) {
                    menuItemRow(title: "Investments Portfolio", desc: "Stocks and Mutual Funds asset valuations", icon: "chart.xyaxis.line")
                }
                
                NavigationLink(destination: LoanEMICalculatorView(viewModel: viewModel, userId: userId)) {
                    menuItemRow(title: "Loans & EMI Calculator", desc: "Calculate debt interest breakdowns", icon: "percent")
                }
                
                NavigationLink(destination: BudgetPlannerView(viewModel: viewModel, userId: userId)) {
                    menuItemRow(title: "Monthly Budget limits", desc: "Manage category limit caps", icon: "chart.bar.doc.horizontal")
                }
                
                NavigationLink(destination: FinancialAnalyticsReportView(viewModel: viewModel, userId: userId)) {
                    menuItemRow(title: "Transaction Reports & Export", desc: "Monthly spreadsheets audits & CSV export", icon: "square.and.arrow.up")
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func menuItemRow(title: String, desc: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#0A84FF"))
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(hex: "#1C1C1E").opacity(0.8))
        .cornerRadius(12)
    }
    
    private func aiInsightsSegment() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI FINANCIAL INTELLIGENCE Insights")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
                .tracking(1.0)
                .padding(.leading, 8)
            
            VStack(spacing: 12) {
                ForEach(insightsVM.adviceCards) { card in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(card.title)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Text(card.category)
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(4)
                                .foregroundColor(.gray)
                        }
                        
                        Text(card.descr)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(Color(hex: "#1C1C1E"))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            insightsVM.compileInsights(
                reserves: viewModel.totalCapitalReserves,
                burn: viewModel.monthlyBurn,
                runway: viewModel.survivalRunwayMonths,
                gains: viewModel.investmentNetGains
            )
        }
    }
}
