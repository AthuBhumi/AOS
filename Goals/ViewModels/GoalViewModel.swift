import Foundation
import Observation
import Models
import Repositories

@Observable
public final class GoalViewModel {
    public var state: GoalState = .idle
    public var goals: [Goal] = []
    
    private let goalRepository: GoalRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    public init(goalRepository: GoalRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.goalRepository = goalRepository
        self.userRepository = userRepository
    }
    
    public func loadGoals(forUser userId: UUID) {
        state = .loading
        do {
            var list = try goalRepository.fetchGoals(forUser: userId)
            
            // Auto generate basic OKRs if empty
            if list.isEmpty {
                let initial = generateDefaultGoals(userId: userId)
                for goal in initial {
                    try goalRepository.saveGoal(goal)
                }
                list = initial
            }
            
            self.goals = list
            state = .loaded(list)
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
    
    public func addNewGoal(title: String, category: String, targetDate: Date, keyResultTitles: [String], forUser userId: UUID) {
        let newGoal = Goal(userId: userId, title: title, category: category, targetDate: targetDate)
        
        let results = keyResultTitles.filter { !$0.isEmpty }.map {
            KeyResult(title: $0, isCompleted: false, goal: newGoal)
        }
        
        newGoal.keyResults = results
        
        do {
            try goalRepository.saveGoal(newGoal)
            loadGoals(forUser: userId)
        } catch {
            state = .failure("Failed to save goal: \(error.localizedDescription)")
        }
    }
    
    public func toggleKeyResult(goalId: UUID, keyResultId: UUID, forUser userId: UUID, completion: @escaping (Bool) -> Void) {
        do {
            let fetched = try goalRepository.fetchGoals(forUser: userId)
            guard let goal = fetched.first(where: { $0.id == goalId }) else {
                completion(false)
                return
            }
            
            guard let index = goal.keyResults.firstIndex(where: { $0.id == keyResultId }) else {
                completion(false)
                return
            }
            
            let result = goal.keyResults[index]
            result.isCompleted.toggle()
            
            // Recalculate parent progress percentage
            let completedCount = goal.keyResults.filter { $0.isCompleted }.count
            goal.progress = (Double(completedCount) / Double(goal.keyResults.count)) * 100.0
            
            try goalRepository.saveGoal(goal)
            
            // If key result was checked, award +30 XP and stats
            if result.isCompleted {
                _ = try userRepository.incrementUserXP(amount: 30, attribute: "CHA", onUser: userId)
                
                // If goal hits 100%, award extra +100 XP
                if goal.progress >= 100.0 {
                    _ = try userRepository.incrementUserXP(amount: 100, attribute: "CHA", onUser: userId)
                }
            }
            
            loadGoals(forUser: userId)
            completion(true)
        } catch {
            state = .failure("KeyResult toggle failed: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    private func generateDefaultGoals(userId: UUID) -> [Goal] {
        let goal = Goal(
            userId: userId,
            title: "Transition to Skilled Developer",
            category: "Career",
            targetDate: Date().addingTimeInterval(86400 * 30),
            progress: 0.0
        )
        
        let results = [
            KeyResult(title: "Complete 3 Java Roadmap topics", isCompleted: false, goal: goal),
            DailyMission(title: "Resolve 10 Coding Sandbox challenges", attribute: "INT", xpReward: 0).id // reusing UUID generator
        ].map { KeyResult(title: $0 is DailyMission ? "Resolve 10 Coding Sandbox challenges" : "Complete 3 Java Roadmap topics", isCompleted: false, goal: goal) }
        
        goal.keyResults = results
        return [goal]
    }
}
