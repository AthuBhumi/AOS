import Foundation
import SwiftData
import Models
import Storage
import Logging

public final class AOSHabitRepository: HabitRepositoryProtocol {
    private let storageManager: AOSStorageManager
    
    public init(storageManager: AOSStorageManager = .shared) {
        self.storageManager = storageManager
    }
    
    private var context: ModelContext {
        guard let context = storageManager.context else {
            AOSLogger.shared.error("AOSHabitRepository requested uninitialized ModelContext.")
            fatalError("SwiftData ModelContext is uninitialized.")
        }
        return context
    }
    
    public func fetchHabits(forUser userId: UUID) throws -> [Habit] {
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.userId == userId && !$0.isDeleted },
            sortBy: [SortDescriptor(\.createdAt, order: .descending)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            AOSLogger.shared.error("Failed to fetch Habits: \(error.localizedDescription)")
            throw StorageError.fetchFailed(error)
        }
    }
    
    public func saveHabit(_ habit: Habit) throws {
        context.insert(habit)
        habit.incrementClock()
        habit.syncState = 2 // Pending Update
        try storageManager.save()
    }
}
