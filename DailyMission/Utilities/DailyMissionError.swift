import Foundation

public enum DailyMissionError: Error, LocalizedError {
    case missionNotFound
    case claimRestricted
    
    public var errorDescription: String? {
        switch self {
        case .missionNotFound:
            return "The requested daily mission task could not be located in local databases."
        case .claimRestricted:
            return "XP rewards claim is restricted. Please complete all today's missions first."
        }
    }
}
