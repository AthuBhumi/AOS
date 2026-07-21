import Foundation
import Observation
import Models
import Repositories

@Observable
public final class DailyMissionViewModel {
    public var state: DailyMissionState = .idle
    public var claimedToday = false
    public var totalRewardXP = 150
    
    private let missionRepository: DailyMissionRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    public init(missionRepository: DailyMissionRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.missionRepository = missionRepository
        self.userRepository = userRepository
    }
    
    public func loadMissions(forDate date: Date, stage: Int) {
        state = .loading
        do {
            var activeMissions = try missionRepository.fetchMissions(forDate: date)
            
            // Generate dummy daily missions if none exist for today
            if activeMissions.isEmpty {
                let generated = generateBaseMissions(forStage: stage, date: date)
                try missionRepository.bulkCreateMissions(generated)
                activeMissions = generated
            }
            
            state = .loaded(activeMissions)
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
    
    public func toggleMission(id: UUID) {
        guard case .loaded(var missions) = state else { return }
        
        do {
            if let index = missions.firstIndex(where: { $0.id == id }) {
                let target = missions[index]
                if !target.isCompleted {
                    _ = try missionRepository.completeMission(byId: id)
                    missions[index].isCompleted = true
                    state = .loaded(missions)
                }
            }
        } catch {
            state = .failure("Unable to check off mission: \(error.localizedDescription)")
        }
    }
    
    public var allMissionsCompleted: Bool {
        guard case .loaded(let missions) = state else { return false }
        return !missions.isEmpty && missions.allSatisfy { $0.isCompleted }
    }
    
    public func claimDailyReward(for userId: UUID, completion: @escaping (Bool) -> Void) {
        guard allMissionsCompleted else {
            state = .failure(DailyMissionError.claimRestricted.localizedDescription)
            completion(false)
            return
        }
        
        guard !claimedToday else {
            completion(false)
            return
        }
        
        do {
            // Reward 150 XP, increase character stats (default Intelligence)
            _ = try userRepository.incrementUserXP(amount: totalRewardXP, attribute: "INT", onUser: userId)
            claimedToday = true
            completion(true)
        } catch {
            state = .failure("XP allocation failed: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    private func generateBaseMissions(forStage stage: Int, date: Date) -> [DailyMission] {
        switch stage {
        case 1:
            return [
                DailyMission(title: "Log 7.5 hrs sleep", attribute: "STR", xpReward: 50, dateScheduled: date),
                DailyMission(title: "Complete 50-minute study focus block", attribute: "INT", xpReward: 50, dateScheduled: date),
                DailyMission(title: "Log Evening Journal reflection", attribute: "CHA", xpReward: 50, dateScheduled: date)
            ]
        case 2:
            return [
                DailyMission(title: "Resolve 1 Java Concurrency problem", attribute: "INT", xpReward: 50, dateScheduled: date),
                DailyMission(title: "Complete 15-minute speed typing drill", attribute: "INT", xpReward: 50, dateScheduled: date)
            ]
        default:
            return [
                DailyMission(title: "Review daily roadmap progression", attribute: "INT", xpReward: 50, dateScheduled: date)
            ]
        }
    }
}
