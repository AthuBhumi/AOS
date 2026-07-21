import Foundation
import Observation
import Models
import Repositories

@Observable
public final class BusinessBuilderViewModel {
    public var state: BusinessBuilderState = .idle
    public var ideas: [StartupIdea] = []
    
    private let businessRepo: BusinessBuilderRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    public init(businessRepo: BusinessBuilderRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.businessRepo = businessRepo
        self.userRepository = userRepository
    }
    
    public func loadIdeas(forUser userId: UUID) {
        state = .loading
        do {
            var list = try businessRepo.fetchIdeas(forUser: userId)
            
            // Seed a default startup if empty
            if list.isEmpty {
                let initial = generateDefaultIdea(userId: userId)
                try businessRepo.saveIdea(initial)
                list = [initial]
            }
            
            self.ideas = list
            state = .loaded
        } catch {
            state = .failure("Unable to fetch business logs: \(error.localizedDescription)")
        }
    }
    
    public func createNewIdea(title: String, targetMarket: String, forUser userId: UUID) {
        let idea = StartupIdea(userId: userId, title: title, targetMarket: targetMarket)
        
        // Seed default compliance items
        idea.complianceItems = [
            ComplianceItem(itemText: "Register Company Name", category: "Registration", startupIdea: idea),
            ComplianceItem(itemText: "Apply for GSTIN Number", category: "GST", startupIdea: idea),
            ComplianceItem(itemText: "Apply for MSME Udyam registration", category: "MSME", startupIdea: idea)
        ]
        
        idea.milestones = [
            StartupMilestone(title: "Define MVP scope", isCompleted: false, startupIdea: idea),
            StartupMilestone(title: "Launch beta landing page", isCompleted: false, startupIdea: idea)
        ]
        
        do {
            try businessRepo.saveIdea(idea)
            loadIdeas(forUser: userId)
        } catch {
            state = .failure("Failed to save idea: \(error.localizedDescription)")
        }
    }
    
    public func commitIdeaDetails(idea: StartupIdea, forUser userId: UUID) {
        idea.updatedAt = Date()
        do {
            try businessRepo.saveIdea(idea)
            
            // Award +50 XP for details edits
            _ = try userRepository.incrementUserXP(amount: 50, attribute: "CHA", onUser: userId)
            
            loadIdeas(forUser: userId)
        } catch {
            state = .failure("Failed to save startup canvas detail: \(error.localizedDescription)")
        }
    }
    
    public func toggleMilestone(ideaId: UUID, milestoneId: UUID, forUser userId: UUID) {
        guard let idea = ideas.first(where: { $0.id == ideaId }) else { return }
        guard let milestone = idea.milestones.first(where: { $0.id == milestoneId }) else { return }
        
        milestone.isCompleted.toggle()
        
        do {
            try businessRepo.saveIdea(idea)
            
            // Award +20 XP for milestones completed
            if milestone.isCompleted {
                _ = try userRepository.incrementUserXP(amount: 20, attribute: "CHA", onUser: userId)
            }
            
            loadIdeas(forUser: userId)
        } catch {
            state = .failure("Milestones update failed: \(error.localizedDescription)")
        }
    }
    
    public func toggleCompliance(ideaId: UUID, itemId: UUID, forUser userId: UUID) {
        guard let idea = ideas.first(where: { $0.id == ideaId }) else { return }
        guard let item = idea.complianceItems.first(where: { $0.id == itemId }) else { return }
        
        item.isCompleted.toggle()
        
        do {
            try businessRepo.saveIdea(idea)
            
            // Award +30 XP for legal checklists checked
            if item.isCompleted {
                _ = try userRepository.incrementUserXP(amount: 30, attribute: "CHA", onUser: userId)
            }
            
            loadIdeas(forUser: userId)
        } catch {
            state = .failure("Compliance update failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Core Startup Analytics Scorers
    public func getExecutionScore(forIdea idea: StartupIdea) -> Double {
        if idea.milestones.isEmpty { return 0.0 }
        let completed = idea.milestones.filter { $0.isCompleted }.count
        return (Double(completed) / Double(idea.milestones.count)) * 100.0
    }
    
    public func getFounderReadiness(forIdea idea: StartupIdea) -> Double {
        // Weighted calculation: Canvas completeness + Compliance completed
        let boxes = [
            idea.problem, idea.solution, idea.uniqueValueProp,
            idea.unfairAdvantage, idea.customerSegments, idea.channels,
            idea.keyMetrics, idea.costStructure, idea.revenueStreams
        ]
        
        let canvasCompleted = boxes.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
        let complianceCompleted = idea.complianceItems.filter { $0.isCompleted }.count
        
        let canvasWeight = Double(canvasCompleted) / 9.0 * 50.0
        let complianceWeight = idea.complianceItems.isEmpty ? 50.0 : (Double(complianceCompleted) / Double(idea.complianceItems.count)) * 50.0
        
        return canvasWeight + complianceWeight
    }
    
    public func getRiskScore(forIdea idea: StartupIdea) -> Double {
        if idea.risks.isEmpty { return 0.0 }
        
        // Risk factor = Sum(Impact * Probability) / 25
        let totalRiskPoints = idea.risks.reduce(0) { $0 + ($1.impact * $1.probability) }
        let maxPoints = Double(idea.risks.count * 25)
        return (Double(totalRiskPoints) / maxPoints) * 100.0
    }
    
    public func getBusinessGrowthScore(forIdea idea: StartupIdea) -> Double {
        // Combine Execution and Founder Readiness
        let exec = getExecutionScore(forIdea: idea)
        let ready = getFounderReadiness(forIdea: idea)
        return (exec * 0.6) + (ready * 0.4)
    }
    
    private func generateDefaultIdea(userId: UUID) -> StartupIdea {
        let idea = StartupIdea(
            userId: userId,
            title: "ATHARVA OS",
            targetMarket: "Indie Hackers & Developers",
            problem: "Developers waste time on manual tracking setups.",
            solution: "An autonomous, local-first developer operating system."
        )
        
        idea.complianceItems = [
            ComplianceItem(itemText: "Register Company Name", category: "Registration", isCompleted: true, startupIdea: idea),
            ComplianceItem(itemText: "Apply for GSTIN Number", category: "GST", isCompleted: false, startupIdea: idea),
            ComplianceItem(itemText: "Apply for MSME registration", category: "MSME", isCompleted: false, startupIdea: idea)
        ]
        
        idea.milestones = [
            StartupMilestone(title: "Build local SwiftData container", isCompleted: true, startupIdea: idea),
            StartupMilestone(title: "Set up SQLCipher encryption key", isCompleted: false, startupIdea: idea)
        ]
        
        idea.risks = [
            RiskRegistration(descr: "Cloud synchronization locks", impact: 4, probability: 3, mitigation: "Use vector clocks sorting", startupIdea: idea)
        ]
        
        return idea
    }
}
