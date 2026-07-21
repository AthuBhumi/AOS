import Foundation
import Models

public protocol JournalRepositoryProtocol {
    func fetchEntries() throws -> [JournalEntry]
    func saveEntry(_ entry: JournalEntry) throws
}
