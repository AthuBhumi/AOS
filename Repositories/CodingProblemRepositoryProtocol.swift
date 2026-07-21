import Foundation
import Models

public protocol CodingProblemRepositoryProtocol {
    func fetchProblems() throws -> [CodingProblem]
    func saveProblem(_ problem: CodingProblem) throws
    func bulkCreateProblems(_ problems: [CodingProblem]) throws
}
