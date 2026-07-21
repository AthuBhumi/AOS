import XCTest
@testable import Common
@testable import Core
@testable import Models
@testable import Storage
@testable import Repositories
@testable import Dashboard

final class AOSDashboardTests: XCTestCase {
    
    // MARK: - Dynamic Hourly Widget Ordering Tests
    func testNightLayoutSortsSleepFirst() {
        let service = AOSDashboardService()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        // Night Time: 11:30 PM (23:30)
        let nightDate = formatter.date(from: "23:30")!
        let context = SensorContext(timeOfDay: nightDate, weatherCondition: "Sunny", energyLevel: 1.0)
        
        let widgets = service.generateLayout(forStage: 1, sensors: context)
        XCTAssertFalse(widgets.isEmpty)
        
        // Asserts that the first widget is Sleep Optimization during night hours
        XCTAssertEqual(widgets.first?.type, .sleepDebt)
    }
    
    func testMiddayLayoutSortsFocusFirst() {
        let service = AOSDashboardService()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        // Midday: 2:00 PM (14:00)
        let middayDate = formatter.date(from: "14:00")!
        let context = SensorContext(timeOfDay: middayDate, weatherCondition: "Sunny", energyLevel: 1.0)
        
        let widgets = service.generateLayout(forStage: 2, sensors: context)
        XCTAssertFalse(widgets.isEmpty)
        
        // Asserts that Active Focus Block is prioritized first during midday focus blocks
        XCTAssertEqual(widgets.first?.type, .activeFocus)
    }
    
    // MARK: - Weather Adaptation Tests
    func testWeatherAltersWidgetTitle() {
        let service = AOSDashboardService()
        let date = Date() // Daytime default
        
        let rainyContext = SensorContext(timeOfDay: date, weatherCondition: "Rainy", energyLevel: 1.0)
        let rainyWidgets = service.generateLayout(forStage: 1, sensors: rainyContext)
        let rainyHabitsWidget = rainyWidgets.first(where: { $0.type == .habitsGrid })
        
        XCTAssertEqual(rainyHabitsWidget?.title, "Indoor Habits Checklist")
        
        let sunnyContext = SensorContext(timeOfDay: date, weatherCondition: "Sunny", energyLevel: 1.0)
        let sunnyWidgets = service.generateLayout(forStage: 1, sensors: sunnyContext)
        let sunnyHabitsWidget = sunnyWidgets.first(where: { $0.type == .habitsGrid })
        
        XCTAssertEqual(sunnyHabitsWidget?.title, "Daily Habits Checklist")
    }
}
