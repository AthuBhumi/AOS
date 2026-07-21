import Foundation
import Observation
import Models

@Observable
public final class AIBusinessMentorViewModel {
    public var swotAdvice = ""
    public var weeklyReportText = ""
    public var isCompiling = false
    
    public init() {}
    
    public func compileSWOTAnalysisAdvice(forIdea idea: StartupIdea) {
        var swotPrompt = "SWOT Evaluation:\n"
        swotPrompt += "- Strengths: \(idea.swotStrengths)\n"
        swotPrompt += "- Weaknesses: \(idea.swotWeaknesses)\n"
        swotPrompt += "- Opportunities: \(idea.swotOpportunities)\n"
        swotPrompt += "- Threats: \(idea.swotThreats)\n"
        
        // Mock compiler logic
        self.swotAdvice = "CBT Reframe for Business Threats: Pivot threats (\(idea.swotThreats)) into opportunities by launching locally-secured client databases."
    }
    
    public func compileWeeklyFounderReport(forIdea idea: StartupIdea, growthScore: Double, readinessScore: Double, riskScore: Double) {
        isCompiling = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: Date())
        
        var report = "===================================\n"
        report += "WEEKLY FOUNDER EXECUTIVE REPORT - \(dateStr)\n"
        report += "Startup: \(idea.title)\n"
        report += "===================================\n\n"
        
        report += String(format: "1. Growth Score: %.1f%%\n", growthScore)
        report += String(format: "2. Execution Readiness: %.1f%%\n", readinessScore)
        report += String(format: "3. Calculated Risk Factor: %.1f%%\n\n", riskScore)
        
        report += "AI RECOMMENDATIONS:\n"
        if growthScore < 50.0 {
            report += "- Roadmap Execution is lagging. Focus on completing defining MVP scope milestones.\n"
        } else {
            report += "- Roadmap execution is healthy. Recommend preparing Investor Pitch Decks.\n"
        }
        
        if idea.complianceItems.filter({ !$0.isCompleted }).count > 0 {
            report += "- Regulatory warnings: Complete pending GSTIN and MSME registrations to open checking accounts.\n"
        }
        
        self.weeklyReportText = report
        self.isCompiling = false
    }
}
