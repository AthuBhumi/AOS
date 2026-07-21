import Foundation
import Models

public enum DailyMissionState: Equatable {
    case idle
    case loading
    case loaded([DailyMission])
    case failure(String)
}
