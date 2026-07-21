import Foundation

public enum CEODashboardState: Equatable {
    case idle
    case loading
    case loaded
    case failure(String)
}
