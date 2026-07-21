import Foundation
import Models

public enum JournalState: Equatable {
    case idle
    case loading
    case loaded([JournalEntry])
    case reframing(JournalEntry)
    case failure(String)
}
