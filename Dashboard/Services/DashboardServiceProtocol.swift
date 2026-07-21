import Foundation
import Dashboard

public protocol DashboardServiceProtocol {
    func generateLayout(forStage stage: Int, sensors: SensorContext) -> [DashboardWidget]
}
