import Foundation
import Models

public protocol BusinessBuilderRepositoryProtocol {
    func fetchIdeas(forUser userId: UUID) throws -> [StartupIdea]
    func saveIdea(_ idea: StartupIdea) throws
}
