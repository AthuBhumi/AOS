import Foundation
import Observation

@Observable
public final class AIFinanceInsightsViewModel {
    public var adviceCards: [FinancialInsightCard] = []
    public var isLoading = false
    
    public init() {}
    
    public func compileInsights(reserves: Double, burn: Double, runway: Double, gains: Double) {
        isLoading = true
        
        var list: [FinancialInsightCard] = []
        
        // Insight 1: Runway Check
        if runway < 6.0 {
            list.append(FinancialInsightCard(
                title: "🔴 Runway Critical",
                descr: String(format: "Your capital runway is down to %.1f months. We recommend auditing Variable Expenses immediately to reduce monthly burn.", runway),
                category: "Risk Alert"
            ))
        } else {
            list.append(FinancialInsightCard(
                title: "🟢 Runway Secure",
                descr: String(format: "Your capital runway is secure at %.1f months. Focus on strategic investments.", runway),
                category: "Stability"
            ))
        }
        
        // Insight 2: Portfolios Check
        if gains > 0 {
            list.append(FinancialInsightCard(
                title: "📈 Portfolio Gains Positive",
                descr: String(format: "Your investments have generated a net gain of $%.2f. Monitor mutual fund asset distributions to secure allocation targets.", gains),
                category: "Investments"
            ))
        } else {
            list.append(FinancialInsightCard(
                title: "⚖️ Portfolio Allocation Stable",
                descr: "Your stock portfolio is stable. Maintain systematic SIP deposits to dollar-cost-average market ranges.",
                category: "Investments"
            ))
        }
        
        self.adviceCards = list
        self.isLoading = false
    }
}

public struct FinancialInsightCard: Identifiable, Equatable {
    public let id = UUID()
    public let title: String
    public let descr: String
    public let category: String
}
