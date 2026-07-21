import Foundation
import Models

public enum CodingState: Equatable {
    case idle
    case loading
    case loaded([RoadmapNode])
    case failure(String)
}
