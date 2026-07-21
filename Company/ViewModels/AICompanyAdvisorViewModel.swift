import Foundation
import Observation
import Models

@Observable
public final class AICompanyAdvisorViewModel {
    public var adviceText = ""
    public var weeklyReportText = ""
    public var isCompiling = false
    
    public init() {}
    
    public func compileWorkloadAdvice(forCompany company: Company) {
        let engineeringCount = company.projects.count
        if engineeringCount > 2 {
            self.adviceText = "Workload alert: 3 active sprint projects mapped to 2 engineers. Recommending hiring 1 junior iOS Engineer to balance load."
        } else {
            self.adviceText = "Workload is stable. Maintain current systematic sprint timelines."
        }
    }
    
    public func compileWeeklyManagementReport(forCompany company: Company, healthScore: Double, progress: Double, profitMargin: Double) {
        isCompiling = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: Date())
        
        var report = "===================================\n"
        report += "WEEKLY EXECUTIVE COMPANY REPORT - \(dateStr)\n"
        report += "Company: \(company.name)\n"
        report += "===================================\n\n"
        
        report += String(format: "1. Corporate Health Score: %.1f%%\n", healthScore)
        report += String(format: "2. Sprint Project Progress: %.1f%%\n", progress)
        report += String(format: "3. Operational Profit Margin: %.1f%%\n\n", profitMargin)
        
        report += "EXECUTIVE SUMMARY & INTERVENTIONS:\n"
        if progress < 50.0 {
            report += "- Sprint delays detected: 2 tasks left in backlog. Audit engineering SOP compliance.\n"
        } else {
            report += "- Operations are running efficiently. Current velocity matches allocation plans.\n"
        }
        
        let unpaidInvoices = company.invoices.filter { !$0.isPaid }
        if !unpaidInvoices.isEmpty {
            let unpaidSum = unpaidInvoices.reduce(0.0) { $0 + $1.amount }
            report += String(format: "- Accounts Receivable Alert: $%.0f is pending in unpaid client invoices. Trigger CRM notices.\n", unpaidSum)
        }
        
        self.weeklyReportText = report
        self.isCompiling = false
    }
}
