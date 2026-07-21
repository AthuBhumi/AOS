import Foundation
import Observation
import Models
import Repositories

@Observable
public final class HabitViewModel {
    public var state: HabitState = .idle
    public var habits: [Habit] = []
    
    private let habitRepository: HabitRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    public init(habitRepository: HabitRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.habitRepository = habitRepository
        self.userRepository = userRepository
    }
    
    public func loadHabits(forUser userId: UUID) {
        state = .loading
        do {
            var list = try habitRepository.fetchHabits(forUser: userId)
            
            // Generate dummy habits if empty
            if list.isEmpty {
                let initial = generateDefaultHabits(userId: userId)
                for habit in initial {
                    try habitRepository.saveHabit(habit)
                }
                list = initial
            }
            
            // Clean/Update streaks on load
            for habit in list {
                updateStreakCheck(habit)
            }
            
            self.habits = list
            state = .loaded(list)
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
    
    public func addNewHabit(title: String, cue: String, response: String, reward: String, forUser userId: UUID) {
        let habit = Habit(
            userId: userId,
            title: title,
            cueText: cue,
            responseText: response,
            rewardText: reward
        )
        
        do {
            try habitRepository.saveHabit(habit)
            loadHabits(forUser: userId)
        } catch {
            state = .failure("Unable to add habit: \(error.localizedDescription)")
        }
    }
    
    public func checkOffHabit(habitId: UUID, forUser userId: UUID, completion: @escaping (Bool) -> Void) {
        do {
            let fetched = try habitRepository.fetchHabits(forUser: userId)
            guard let habit = fetched.first(where: { $0.id == habitId }) else {
                completion(false)
                return
            }
            
            let today = Calendar.current.startOfDay(for: Date())
            if habit.completionHistory.contains(today) {
                // Already completed today
                completion(false)
                return
            }
            
            // Log completion
            habit.completionHistory.append(today)
            
            // Update Streak
            let yesterday = today.addingTimeInterval(-86400)
            if habit.completionHistory.contains(yesterday) {
                habit.activeStreak += 1
            } else {
                habit.activeStreak = 1
            }
            
            try habitRepository.saveHabit(habit)
            
            // Award +10 XP for compliance
            _ = try userRepository.incrementUserXP(amount: 10, attribute: "STR", onUser: userId)
            
            loadHabits(forUser: userId)
            completion(true)
        } catch {
            state = .failure("Check-off write failed: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // MARK: - Streak & Compliance Analytics Helpers
    private func updateStreakCheck(_ habit: Habit) {
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = today.addingTimeInterval(-86400)
        
        if !habit.completionHistory.contains(today) && !habit.completionHistory.contains(yesterday) {
            // Streak broken: missed yesterday and today
            habit.activeStreak = 0
            try? habitRepository.saveHabit(habit)
        }
    }
    
    public func getComplianceRate(_ habit: Habit) -> Double {
        if habit.completionHistory.isEmpty { return 0.0 }
        
        let today = Calendar.current.startOfDay(for: Date())
        var completedCount = 0
        
        // Loop last 30 days
        for i in 0..<30 {
            let targetDay = today.addingTimeInterval(Double(-i) * 86400)
            if habit.completionHistory.contains(targetDay) {
                completedCount += 1
            }
        }
        
        return (Double(completedCount) / 30.0) * 100.0
    }
    
    private func generateDefaultHabits(userId: UUID) -> [Book] { // Maps base habits
        return [
            Habit(userId: userId, title: "Java Syntax Study", cueText: "After I open my laptop at 9 AM", responseText: "I will study Java roadmap lessons for 50 mins", rewardText: "I will gain skill XP points"),
            Habit(userId: userId, title: "Evening Reflection Journal", cueText: "After I plug my phone in to charge at night", responseText: "I will log my journaling check-in", rewardText: "I will protect my daily streaks")
        ]
    }
}
