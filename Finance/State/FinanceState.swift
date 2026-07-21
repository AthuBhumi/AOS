import Foundation
import Models

public enum FinanceState: Equatable {
    case idle
    case loading
    case loaded
    case failure(String)
}
