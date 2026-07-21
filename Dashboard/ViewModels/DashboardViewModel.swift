import Foundation
import Observation
import Models
import Repositories
import Dashboard

@Observable
public final class DashboardViewModel {
    public var widgets: [DashboardWidget] = []
    public var sensorContext = SensorContext()
    public var user: User?
    public var isLoading = false
    public var errorMessage: String?
    
    private let dashboardService: DashboardServiceProtocol
    private let userRepository: UserRepositoryProtocol
    
    public init(dashboardService: DashboardServiceProtocol, userRepository: UserRepositoryProtocol) {
        self.dashboardService = dashboardService
        self.userRepository = userRepository
    }
    
    public func loadDashboard(for userId: UUID) {
        isLoading = true
        errorMessage = nil
        
        do {
            if let userRecord = try userRepository.fetchUser(byId: userId) {
                self.user = userRecord
                // Generates dynamic layout matching stage and active sensors
                self.widgets = dashboardService.generateLayout(
                    forStage: userRecord.currentStage,
                    sensors: sensorContext
                )
                isLoading = false
            } else {
                errorMessage = "User profile not found."
                isLoading = false
            }
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    public func updateSensors(time: Date, weather: String) {
        sensorContext = SensorContext(timeOfDay: time, weatherCondition: weather, energyLevel: sensorContext.energyLevel)
        if let user = user {
            self.widgets = dashboardService.generateLayout(forStage: user.currentStage, sensors: sensorContext)
        }
    }
}
