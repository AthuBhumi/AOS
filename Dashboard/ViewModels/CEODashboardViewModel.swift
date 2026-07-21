import Foundation
import Observation
import Models
import Repositories

@Observable
public final class CEODashboardViewModel {
    public var state: CEODashboardState = .idle
    public var decisions: [CEODecision] = []
    
    // Aggregated Metrics Cache
    public var totalNetWorth: Double = 0.0
    public var monthlyBurn: Double = 0.0
    public var runwayMonths: Double = 0.0
    
    public var executionScore: Double = 0.0
    public var founderReadiness: Double = 0.0
    public var leadershipScore: Double = 0.0
    public var lifeBalanceScore: Double = 0.0
    public var overallScore: Double = 0.0
    
    // Repositories
    private let decisionRepo: CEODecisionRepositoryProtocol
    private let userRepo: UserRepositoryProtocol
    private let companyRepo: CompanyBuilderRepositoryProtocol
    private let businessRepo: BusinessBuilderRepositoryProtocol
    private let financeRepo: AdvancedFinanceRepositoryProtocol
    private let habitRepo: HabitRepositoryProtocol
    private let goalRepo: GoalRepositoryProtocol
    
    public init(
        decisionRepo: CEODecisionRepositoryProtocol,
        userRepo: UserRepositoryProtocol,
        companyRepo: CompanyBuilderRepositoryProtocol,
        businessRepo: BusinessBuilderRepositoryProtocol,
        financeRepo: AdvancedFinanceRepositoryProtocol,
        habitRepo: HabitRepositoryProtocol,
        goalRepo: GoalRepositoryProtocol
    ) {
        self.decisionRepo = decisionRepo
        self.userRepo = userRepo
        self.companyRepo = companyRepo
        self.businessRepo = businessRepo
        self.financeRepo = financeRepo
        self.habitRepo = habitRepo
        self.goalRepo = goalRepo
    }
    
    public func loadAllData(forUser userId: UUID) {
        state = .loading
        do {
            // Load Decisions Queue
            var fetchedDecisions = try decisionRepo.fetchDecisions(forUser: userId)
            if fetchedDecisions.isEmpty {
                let initial = [
                    CEODecision(userId: userId, title: "Approve budget reallocation to marketing SIPs", optionsList: "Approve, Reject, Delay"),
                    CEODecision(userId: userId, title: "Hire a junior Swift Dev to handle PR backlog", optionsList: "Hire immediately, Wait 1 month, Reject")
                ]
                for d in initial {
                    try decisionRepo.saveDecision(d)
                }
                fetchedDecisions = initial
            }
            self.decisions = fetchedDecisions
            
            // 1. Fetch Finance Stats (Reserves + Portfolio AAPL/Mutual fund)
            let cash = try financeRepo.fetchAccounts(forUser: userId).filter({ $0.type == "Cash" }).reduce(0.0) { $0 + $1.balance }
            let fds = try financeRepo.fetchFixedDeposits(forUser: userId).reduce(0.0) { $0 + $1.principal }
            let investments = try financeRepo.fetchInvestments(forUser: userId).reduce(0.0) { $0 + ($1.currentPrice * $1.quantity) }
            
            let expenses = try financeRepo.fetchTransactions(forUser: userId).filter({ $0.category.contains("Expense") }).reduce(0.0) { $0 + $1.amount }
            
            self.totalNetWorth = cash + fds + investments
            self.monthlyBurn = expenses
            self.runwayMonths = expenses > 0 ? ((cash + fds) / expenses) : 99.0
            
            // 2. Fetch Business Startup details (Atharva OS Startup Growth Score)
            if let startup = try businessRepo.fetchIdeas(forUser: userId).first {
                let boxes = [startup.problem, startup.solution, startup.uniqueValueProp, startup.unfairAdvantage, startup.customerSegments, startup.channels, startup.keyMetrics, startup.costStructure, startup.revenueStreams]
                let canvasCount = boxes.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
                let complianceCompleted = startup.complianceItems.filter { $0.isCompleted }.count
                
                let canvasWeight = Double(canvasCount) / 9.0 * 50.0
                let complianceWeight = startup.complianceItems.isEmpty ? 50.0 : (Double(complianceCompleted) / Double(startup.complianceItems.count)) * 50.0
                self.founderReadiness = canvasWeight + complianceWeight
                
                let milestonesCompleted = startup.milestones.filter { $0.isCompleted }.count
                let milestonesTotal = startup.milestones.count
                let execWeight = milestonesTotal > 0 ? (Double(milestonesCompleted) / Double(milestonesTotal)) * 100.0 : 100.0
                self.executionScore = execWeight
            } else {
                self.founderReadiness = 50.0
                self.executionScore = 50.0
            }
            
            // 3. Fetch Company Team stats (Atharva Technologies Pvt Ltd)
            if let company = try companyRepo.fetchCompanies(forUser: userId).first {
                let progress = company.projects.isEmpty ? 100.0 : (Double(company.projects.filter({ $0.status == "Done" }).count) / Double(company.projects.count)) * 100.0
                let attend = company.employees.isEmpty ? 20 : company.employees.reduce(0) { $0 + $1.attendanceDays }
                let maxPossible = company.employees.isEmpty ? 20 : company.employees.count * 20
                let attendanceRate = (Double(attend) / Double(maxPossible)) * 100.0
                
                self.leadershipScore = (progress * 0.6) + (attendanceRate * 0.4)
            } else {
                self.leadershipScore = 60.0
            }
            
            // 4. Fetch User Stats (INT, STR, CHA)
            if let user = try userRepo.fetchUser(byId: userId) {
                let statsSum = Double(user.intelligenceStat + user.strengthStat + user.charismaStat)
                self.lifeBalanceScore = min(100.0, (statsSum / 15.0) * 100.0) // assumes max baseline stats level 5
            } else {
                self.lifeBalanceScore = 50.0
            }
            
            // 5. Aggregate overall executive rating score
            self.overallScore = (executionScore + founderReadiness + leadershipScore + lifeBalanceScore) / 4.0
            
            state = .loaded
        } catch {
            state = .failure("Failed to compile executive indices: \(error.localizedDescription)")
        }
    }
    
    public func resolveDecision(decisionId: UUID, chosenOption: String, forUser userId: UUID) {
        guard let index = decisions.firstIndex(where: { $0.id == decisionId }) else { return }
        let decision = decisions[index]
        decision.isResolved = true
        decision.chosenOption = chosenOption
        
        do {
            try decisionRepo.saveDecision(decision)
            
            // Award +40 XP for resolving high priority corporate choices
            _ = try userRepo.incrementUserXP(amount: 40, attribute: "CHA", onUser: userId)
            
            loadAllData(forUser: userId)
        } catch {
            state = .failure("Failed to resolve decision: \(error.localizedDescription)")
        }
    }
    
    public func addNewDecision(title: String, options: String, forUser userId: UUID) {
        let d = CEODecision(userId: userId, title: title, optionsList: options)
        do {
            try decisionRepo.saveDecision(d)
            loadAllData(forUser: userId)
        } catch {
            state = .failure("Failed to add decision: \(error.localizedDescription)")
        }
    }
    
    // MARK: - CSV Exporter
    public func compileCEOCSVReport() -> String {
        var csv = "Metric,Value,Rating\n"
        csv += "Overall Executive Score,\(Int(overallScore))%,High\n"
        csv += "Founder Readiness,\(Int(founderReadiness))%,Moderate\n"
        csv += "Execution Capacity,\(Int(executionScore))%,High\n"
        csv += "Corporate Leadership,\(Int(leadershipScore))%,Stable\n"
        csv += "Life Balance Ratio,\(Int(lifeBalanceScore))%,Healthy\n"
        csv += "Capital Reserves Cash,$\(Int(totalNetWorth)),Stable\n"
        csv += "Survival Runway,\(String(format: "%.1f", runwayMonths)) mos,Secure\n"
        return csv
    }
}
