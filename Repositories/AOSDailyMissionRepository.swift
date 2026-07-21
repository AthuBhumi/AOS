import Foundation
import SwiftData
import Models
import Storage
import Logging

public final class AOSDailyMissionRepository: DailyMissionRepositoryProtocol {
    private let storageManager: AOSStorageManager
    
    public init(storageManager: AOSStorageManager = .shared) {
        self.storageManager = storageManager
    }
    
    private var context: ModelContext {
        guard let context = storageManager.context else {
            AOSLogger.shared.error("AOSDailyMissionRepository requested uninitialized ModelContext.")
            fatalError("SwiftData ModelContext is uninitialized.")
        }
        return context
    }
    
    public func fetchMissions(forDate date: Date) throws -> [DailyMission] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        
        let descriptor = FetchDescriptor<DailyMission>(
            predicate: #Predicate { $0.dateScheduled >= startOfDay && $0.dateScheduled < endOfDay && !$0.isDeleted }
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            AOSLogger.shared.error("Failed to fetch DailyMissions from database: \(error.localizedDescription)")
            throw StorageError.fetchFailed(error)
        }
    }
    
    public func saveMission(_ mission: DailyMission) throws {
        context.insert(mission)
        mission.incrementClock()
        mission.syncState = 2 // Pending Update
        try storageManager.save()
    }
    
    public func completeMission(byId id: UUID) throws -> DailyMission? {
        let descriptor = FetchDescriptor<DailyMission>(predicate: #Predicate { $0.id == id })
        do {
            let results = try context.fetch(descriptor)
            guard let mission = results.first else { return nil }
            
            mission.isCompleted = true
            mission.incrementClock()
            mission.syncState = 2 // Pending Update
            try storageManager.save()
            return mission
        } catch {
            AOSLogger.shared.error("Failed to check off DailyMission: \(error.localizedDescription)")
            throw StorageError.saveFailed(error)
        }
    }
    
    public func bulkCreateMissions(_ missions: [DailyMission]) throws {
        for mission in missions {
            context.insert(mission)
            mission.syncState = 1 // Pending Create
        }
        try storageManager.save()
    }
}
