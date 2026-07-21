import SwiftUI
import Models

public struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    private let userId: UUID
    @State private var showEditSheet = false
    
    public init(viewModel: ProfileViewModel, userId: UUID) {
        _viewModel = State(initialValue: viewModel)
        self.userId = userId
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
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Button("Retry") {
                        viewModel.loadProfile(userId: userId)
                    }
                    .foregroundColor(Color(hex: "#0A84FF"))
                }
                
            case .loaded(let user):
                ScrollView {
                    VStack(spacing: 24) {
                        // Header card
                        VStack(spacing: 12) {
                            // Avatar Placeholder
                            Circle()
                                .fill(Color(hex: "#1C1C1E"))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.gray)
                                )
                            
                            Text(user.displayName ?? "User Profile")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            // Stage Badge
                            Text(viewModel.getStageName(for: user.currentStage))
                                .font(.system(size: 13, weight: .semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: "#BF5AF2").opacity(0.2))
                                .foregroundColor(Color(hex: "#BF5AF2"))
                                .cornerRadius(8)
                        }
                        .padding(.top, 24)
                        
                        // TIS Radial Progress Ring
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 10)
                                    .frame(width: 140, height: 140)
                                
                                Circle()
                                    .trim(from: 0.0, to: CGFloat(user.transformationIndexScore / 100.0))
                                    .stroke(Color(hex: "#0A84FF"), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                    .frame(width: 140, height: 140)
                                    .rotationEffect(.degrees(-90))
                                
                                VStack {
                                    Text(String(format: "%.1f", user.transformationIndexScore))
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("TIS Score")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        // RPG Stats Indicators
                        VStack(alignment: .leading, spacing: 16) {
                            Text("CHARACTER STATISTICS")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.gray)
                                .padding(.leading, 8)
                            
                            VStack(spacing: 12) {
                                statRow(title: "Strength (STR) - Gym & Sleep", value: user.strengthStat, color: "#30D158", icon: "figure.run")
                                statRow(title: "Intelligence (INT) - Coding & Study", value: user.intelligenceStat, color: "#0A84FF", icon: "brain.head.profile")
                                statRow(title: "Charisma (CHA) - Speech & Comm", value: user.charismaStat, color: "#BF5AF2", icon: "mouth")
                                statRow(title: "Fortune (FOR) - Finance & Assets", value: user.fortuneStat, color: "#FFD60A", icon: "dollarsign.circle")
                            }
                            .padding(16)
                            .background(Color(hex: "#1C1C1E").opacity(0.7))
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                        
                        // Action items
                        Button(action: { showEditSheet = true }) {
                            Text("Edit Profile Details")
                                .font(.system(size: 17, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadProfile(userId: userId)
        }
        .sheet(isPresented: $showEditSheet) {
            EditProfileView(viewModel: viewModel, userId: userId)
        }
    }
    
    private func statRow(title: String, value: Int, color: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(hex: color))
                .frame(width: 28)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Spacer()
            
            Text("Lvl \(value)")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
        }
    }
}
