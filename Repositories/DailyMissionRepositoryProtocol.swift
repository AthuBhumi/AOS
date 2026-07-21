import Foundation
import Models

public protocol DailyMissionRepositoryProtocol {
    func fetchMissions(forDate date: Date) throws -> [DailyMission]
    func saveMission(_ mission: DailyMission) throws
    func completeMission(byId id: UUID) throws -> DailyMission?
    func bulkCreateMissions(_ missions: [DailyMission]) throws
}
