import SwiftUI
import Models

public struct DeveloperWorkspaceView: View {
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
                        case .activeFocus:
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Volatile Keyword study")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("Next Scheduled: 9:00 AM")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Button(action: {}) {
                                    Image(systemName: "play.fill")
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(Color(hex: "#0A84FF"))
                                        .clipShape(Circle())
                                }
                            }
                        case .codingRoadmap:
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Java Concurrency Threading")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                ProgressView(value: 0.65)
                                    .accentColor(Color(hex: "#BF5AF2"))
                                HStack {
                                    Text("65% Completed")
                                        .font(.system(size: 11))
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("120 XP earned")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color(hex: "#BF5AF2"))
                                }
                            }
                        default:
                            Text("Roadmaps unlocked.")
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
        case .activeFocus: return "play.circle.fill"
        case .codingRoadmap: return "network"
        default: return "circle.grid.2x2"
        }
    }
}
