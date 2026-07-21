import SwiftUI
import Models

public struct DailyMissionView: View {
    @State private var viewModel: DailyMissionViewModel
    private let userId: UUID
    private let activeStage: Int
    @State private var showConfetti = false
    
    public init(viewModel: DailyMissionViewModel, userId: UUID, activeStage: Int) {
        _viewModel = State(initialValue: viewModel)
        self.userId = userId
        self.activeStage = activeStage
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
            case .failure(let error):
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 44))
                        .foregroundColor(Color(hex: "#FF453A"))
                    Text(error)
                        .foregroundColor(.white)
                    Button("Retry") { viewModel.loadMissions(forDate: Date(), stage: activeStage) }
                        .foregroundColor(Color(hex: "#0A84FF"))
                }
                
            case .loaded(let missions):
                VStack(spacing: 24) {
                    // Header progress dial
                    VStack(spacing: 8) {
                        Text("DAILY MISSION CHECKLIST")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                            .tracking(1.5)
                        
                        Text(viewModel.allMissionsCompleted ? "Missions Complete!" : "Focus & Execute")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 24)
                    
                    // Checklist Card
                    VStack(spacing: 0) {
                        ForEach(missions) { mission in
                            HStack {
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        viewModel.toggleMission(id: mission.id)
                                    }
                                }) {
                                    Image(systemName: mission.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 24))
                                        .foregroundColor(mission.isCompleted ? Color(hex: "#30D158") : .gray)
                                }
                                
                                Text(mission.title)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(mission.isCompleted ? .gray : .white)
                                    .strikethrough(mission.isCompleted, color: .gray)
                                    .padding(.leading, 8)
                                
                                Spacer()
                                
                                Text("+\(mission.xpReward) XP")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(hex: "#BF5AF2"))
                            }
                            .padding(.vertical, 16)
                            
                            if mission != missions.last {
                                Divider()
                                    .background(Color.white.opacity(0.1))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .background(Color(hex: "#1C1C1E").opacity(0.7))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Claim Reward Button
                    if viewModel.claimedToday {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 32))
                                .foregroundColor(Color(hex: "#30D158"))
                            Text("Reward Claimed")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.bottom, 40)
                    } else {
                        Button(action: {
                            viewModel.claimDailyReward(for: userId) { success in
                                if success {
                                    withAnimation(.spring()) {
                                        showConfetti = true
                                    }
                                }
                            }
                        }) {
                            Text("Claim +\(viewModel.totalRewardXP) XP Bonus")
                                .font(.system(size: 17, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.allMissionsCompleted ? Color(hex: "#30D158") : Color.gray.opacity(0.2))
                                .foregroundColor(viewModel.allMissionsCompleted ? .black : .gray)
                                .cornerRadius(12)
                        }
                        .disabled(!viewModel.allMissionsCompleted)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadMissions(forDate: Date(), stage: activeStage)
        }
    }
}
