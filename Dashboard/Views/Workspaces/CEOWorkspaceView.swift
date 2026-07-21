import SwiftUI
import Models

public struct CEOWorkspaceView: View {
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
                        case .companyOKRs:
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Release ATHARVA OS Beta")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                ProgressView(value: 0.45)
                                    .accentColor(Color(hex: "#30D158"))
                                Text("Key Result: Secure 200 testers (45% completed)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                        case .financeRunway:
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("$120,000 Cash Reserves")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.white)
                                    Text("8.0 Months of Business Runway")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(hex: "#30D158"))
                            }
                        default:
                            Text("Executive systems active.")
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
        case .companyOKRs: return "checklist.checked"
        case .financeRunway: return "building.columns.fill"
        default: return "circle.grid.2x2"
        }
    }
}
