import Foundation
import Models

public protocol HabitRepositoryProtocol {
    func fetchHabits(forUser userId: UUID) throws -> [Habit]
    func saveHabit(_ habit: Habit) throws
}
