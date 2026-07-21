import Foundation

public enum WidgetType: String, Codable {
    case sleepDebt = "SLEEP_DEBT"
    case dailyMission = "DAILY_MISSION"
    case habitsGrid = "HABITS_GRID"
    case activeFocus = "ACTIVE_FOCUS"
    case codingRoadmap = "CODING_ROADMAP"
    case speechPitch = "SPEECH_PITCH"
    case financeRunway = "FINANCE_RUNWAY"
    case companyOKRs = "COMPANY_OKRS"
}

public struct DashboardWidget: Identifiable, Codable, Equatable {
    public let id: UUID
    public let title: String
    public let type: WidgetType
    public let displayOrder: Int
    
    public init(id: UUID = UUID(), title: String, type: WidgetType, displayOrder: Int) {
        self.id = id
        self.title = title
        self.type = type
        self.displayOrder = displayOrder
    }
}
