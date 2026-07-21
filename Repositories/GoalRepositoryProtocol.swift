import Foundation
import Models

public protocol GoalRepositoryProtocol {
    func fetchGoals(forUser userId: UUID) throws -> [Goal]
    func saveGoal(_ goal: Goal) throws
}
