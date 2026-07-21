import Foundation
import Models

public enum GoalState: Equatable {
    case idle
    case loading
    case loaded([Goal])
    case failure(String)
}
