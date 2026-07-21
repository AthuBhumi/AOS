import Foundation
import Models

public protocol TypingRepositoryProtocol {
    func fetchSessions(forUser userId: UUID) throws -> [TypingSession]
    func saveSession(_ session: TypingSession) throws
}
