import Foundation
import Models

public protocol ChatMessageRepositoryProtocol {
    func fetchMessages(forUser userId: UUID, advisor: String, limit: Int) throws -> [ChatMessage]
    func saveMessage(_ message: ChatMessage) throws
    func clearHistory(forUser userId: UUID, advisor: String) throws
}
