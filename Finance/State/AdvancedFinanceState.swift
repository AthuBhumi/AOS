import Foundation

public enum AdvancedFinanceState: Equatable {
    case idle
    case loading
    case loaded
    case failure(String)
}
