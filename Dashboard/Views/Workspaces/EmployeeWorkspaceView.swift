import SwiftUI
import Models

public struct EmployeeWorkspaceView: View {
    let widgets: [DashboardWidget]
    
    public init(widgets: [DashboardWidget]) {
        self.widgets = widgets
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            ForEach(widgets) { widget in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: icon(for: widget.type))
                            .foregroundColor(Color(hex: "#0A84FF"))
                        Text(widget.title)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    // Render inner widget preview contents
                    Group {
                        switch widget.type {
                        case .sleepDebt:
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("0.8 Hours")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Current Sleep Debt")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "powersleep")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(hex: "#30D158"))
                            }
                        case .habitsGrid:
                            VStack(spacing: 8) {
                                habitItem(title: "Log 7.5 hrs sleep", completed: true)
                                habitItem(title: "50-minute Java study", completed: false)
                                habitItem(title: "Morning journaling", completed: false)
                            }
                        default:
                            Text("Complete daily missions to level up stats.")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(16)
                .background(Color(hex: "#1C1C1E").opacity(0.7))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
        }
    }
    
    private func icon(for type: WidgetType) -> String {
        switch type {
        case .sleepDebt: return "bed.double.fill"
        case .habitsGrid: return "checklist"
        case .dailyMission: return "target"
        default: return "circle.grid.2x2"
        }
    }
    
    private func habitItem(title: String, completed: Bool) -> some View {
        HStack {
            Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                .foregroundColor(completed ? Color(hex: "#30D158") : .gray)
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white)
            Spacer()
        }
    }
}
