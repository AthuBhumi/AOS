import Foundation
import Models

public enum HabitState: Equatable {
    case idle
    case loading
    case loaded([Habit])
    case failure(String)
}
