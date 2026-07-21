import Foundation
import Observation

@Observable
public final class AICEODecisionAdvisorViewModel {
    public var reportText = ""
    public var isCompiling = false
    
    public init() {}
    
    public func compileQuarterlyBusinessReview(
        overall: Double,
        readiness: Double,
        exec: Double,
        leadership: Double,
        balance: Double,
        runway: Double
    ) {
        isCompiling = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: Date())
        
        var report = "===================================\n"
        report += "CEO QUARTERLY EXECUTIVE REVIEW (QBR) - \(dateStr)\n"
        report += "ATHARVA OS GLOBAL COMMAND CONTROL\n"
        report += "===================================\n\n"
        
        report += String(format: "Overall Performance Rating: %.1f%%\n\n", overall)
        report += String(format: "- Execution score: %.1f%%\n", exec)
        report += String(format: "- Leadership metrics: %.1f%%\n", leadership)
        report += String(format: "- Founder Readiness index: %.1f%%\n", readiness)
        report += String(format: "- Life Balance score: %.1f%%\n", balance)
        report += String(format: "- Survival runway: %.1f months\n\n", runway)
        
        report += "AI EXECUTIVE INTERVENTIONS:\n"
        if runway < 6.0 {
            report += "- CRITICAL WARNING: Runway is under 6 months. Instruct CFO to suspend variable expense allocations.\n"
        } else {
            report += "- Capital levels are secure. Approve R&D expansions.\n"
        }
        
        if balance < 60.0 {
            report += "- Burnout alert: Life Balance Score is low. Schedule gym workouts and journal prompts.\n"
        } else {
            report += "- Founder life-work alignment is healthy.\n"
        }
        
        self.reportText = report
        self.isCompiling = false
    }
}
