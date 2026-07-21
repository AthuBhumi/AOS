import Foundation
import Models

public protocol CEODecisionRepositoryProtocol {
    func fetchDecisions(forUser userId: UUID) throws -> [CEODecision]
    func saveDecision(_ decision: CEODecision) throws
}
