import Foundation
import Dashboard

public final class AOSDashboardService: DashboardServiceProtocol {
    
    public init() {}
    
    public func generateLayout(forStage stage: Int, sensors: SensorContext) -> [DashboardWidget] {
        var widgets: [DashboardWidget] = []
        
        // Base Stage-Specific allocations
        switch stage {
        case 1: // Employee
            widgets.append(DashboardWidget(title: "Sleep Optimization", type: .sleepDebt, displayOrder: 1))
            
            // Adjust title based on weather parameters
            let habitsTitle = (sensors.weatherCondition == "Rainy") ? "Indoor Habits Checklist" : "Daily Habits Checklist"
            widgets.append(DashboardWidget(title: habitsTitle, type: .habitsGrid, displayOrder: 2))
            widgets.append(DashboardWidget(title: "Today's Mission", type: .dailyMission, displayOrder: 3))
            
        case 2: // Skilled Developer
            widgets.append(DashboardWidget(title: "Active Focus Block", type: .activeFocus, displayOrder: 1))
            widgets.append(DashboardWidget(title: "Java & DSA Roadmap", type: .codingRoadmap, displayOrder: 2))
            
        case 3: // Entrepreneur
            widgets.append(DashboardWidget(title: "Pitch Recorder", type: .speechPitch, displayOrder: 1))
            widgets.append(DashboardWidget(title: "Capital Runway Ledger", type: .financeRunway, displayOrder: 2))
            
        case 4: // CEO
            widgets.append(DashboardWidget(title: "Company OKR Mapping", type: .companyOKRs, displayOrder: 1))
            widgets.append(DashboardWidget(title: "Cash Burn & Runway", type: .financeRunway, displayOrder: 2))
            
        default:
            widgets.append(DashboardWidget(title: "Today's Mission", type: .dailyMission, displayOrder: 1))
        }
        
        // Adjust ordering dynamically based on Time of Day (Hourly check)
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: sensors.timeOfDay)
        
        if hour >= 22 || hour < 5 {
            // Night layout: Prioritize Sleep widgets if available
            widgets.sort { (w1, w2) -> Bool in
                if w1.type == .sleepDebt { return true }
                if w2.type == .sleepDebt { return false }
                return w1.displayOrder < w2.displayOrder
            }
        } else if hour >= 9 && hour < 17 {
            // Midday: Prioritize Focus block if available
            widgets.sort { (w1, w2) -> Bool in
                if w1.type == .activeFocus { return true }
                if w2.type == .activeFocus { return false }
                return w1.displayOrder < w2.displayOrder
            }
        }
        
        return widgets
    }
}
