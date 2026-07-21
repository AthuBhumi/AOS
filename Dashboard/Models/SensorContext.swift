import Foundation

public struct SensorContext: Equatable {
    public let timeOfDay: Date
    public let weatherCondition: String // e.g. "Sunny", "Rainy", "Cold"
    public let energyLevel: Double // derived from Sleep Debt
    
    public init(timeOfDay: Date = Date(), weatherCondition: String = "Sunny", energyLevel: Double = 1.0) {
        self.timeOfDay = timeOfDay
        self.weatherCondition = weatherCondition
        self.energyLevel = energyLevel
    }
}
