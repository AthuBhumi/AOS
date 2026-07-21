import SwiftUI
import Models

public struct EntrepreneurWorkspaceView: View {
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
                    
                    Group {
                        switch widget.type {
                        case .speechPitch:
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Rhetorical Pitch practice")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("Last Score: Grade B (8 filler words)")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(hex: "#BF5AF2"))
                            }
                        case .financeRunway:
                            VStack(alignment: .leading, spacing: 8) {
                                Text("6.8 Months")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Survival Runway (Savings vs Expenses)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                        default:
                            Text("Entrepreneur tools unlocked.")
                                .foregroundColor(.gray)
                        }
                    }
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
        case .speechPitch: return "mic.circle.fill"
        case .financeRunway: return "dollarsign.circle.fill"
        default: return "circle.grid.2x2"
        }
    }
}
