import SwiftUI
import Models

public struct DashboardView: View {
    @State private var viewModel: DashboardViewModel
    private let userId: UUID
    
    public init(viewModel: DashboardViewModel, userId: UUID) {
        _viewModel = State(initialValue: viewModel)
        self.userId = userId
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 44))
                            .foregroundColor(Color(hex: "#FF453A"))
                        Text(error)
                            .foregroundColor(.white)
                        Button("Retry") { viewModel.loadDashboard(for: userId) }
                            .foregroundColor(Color(hex: "#0A84FF"))
                    }
                } else if let user = viewModel.user {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Dynamic Header Widget
                            headerSection(user: user)
                            
                            // Load Stage-Specific workspace layouts
                            switch user.currentStage {
                            case 1:
                                EmployeeWorkspaceView(widgets: viewModel.widgets)
                            case 2:
                                DeveloperWorkspaceView(widgets: viewModel.widgets)
                            case 3:
                                EntrepreneurWorkspaceView(widgets: viewModel.widgets)
                            case 4:
                                CEOWorkspaceView(widgets: viewModel.widgets)
                            default:
                                EmployeeWorkspaceView(widgets: viewModel.widgets)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .refreshable {
                        viewModel.loadDashboard(for: userId)
                    }
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                }
            }
            .onAppear {
                viewModel.loadDashboard(for: userId)
            }
        }
    }
    
    private func headerSection(user: User) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("STAGE LEVEL \(user.currentStage)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(hex: "#BF5AF2"))
                    .tracking(1.0)
                
                Text("Atharva's Workspace")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            Spacer()
            
            // Sensor Indicator Pills
            HStack(spacing: 8) {
                Label(viewModel.sensorContext.weatherCondition, systemImage: "cloud.sun.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.1))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 12)
    }
}
