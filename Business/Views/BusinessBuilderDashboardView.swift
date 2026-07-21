import SwiftUI
import Models

public struct BusinessBuilderDashboardView: View {
    @State private var viewModel: BusinessBuilderViewModel
    private let userId: UUID
    @State private var showRegisterSheet = false
    @State private var newTitle = ""
    @State private var newMarket = ""
    
    public init(viewModel: BusinessBuilderViewModel, userId: UUID) {
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
                    Button("Retry") { viewModel.loadIdeas(forUser: userId) }
                        .foregroundColor(Color(hex: "#0A84FF"))
                }
                
            case .loaded:
                ScrollView {
                    VStack(spacing: 24) {
                        // High-level growth indicator
                        growthStatsOverview()
                        
                        // Startups list
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ACTIVE VENTURES")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1.0)
                                .padding(.leading, 8)
                            
                            ForEach(viewModel.ideas) { idea in
                                NavigationLink(destination: StartupIdeaDetailView(viewModel: viewModel, idea: idea, userId: userId)) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(idea.title)
                                                .font(.system(size: 17, weight: .bold))
                                                .foregroundColor(.white)
                                            Text("Market: \(idea.targetMarket)")
                                                .font(.system(size: 13))
                                                .foregroundColor(.gray)
                                            
                                            // Growth score progress
                                            let score = viewModel.getBusinessGrowthScore(forIdea: idea)
                                            ProgressView(value: score / 100.0)
                                                .accentColor(Color(hex: "#BF5AF2"))
                                                .scaleEffect(x: 1, y: 1.2, anchor: .leading)
                                                .padding(.top, 4)
                                        }
                                        Spacer()
                                        
                                        let growth = viewModel.getBusinessGrowthScore(forIdea: idea)
                                        Text(String(format: "%.0f%% Growth", growth))
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(Color(hex: "#1C1C1E").opacity(0.7))
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadIdeas(forUser: userId)
        }
        .navigationTitle("Business Builder")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showRegisterSheet = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showRegisterSheet) {
            registerStartupSheet()
        }
    }
    
    private func growthStatsOverview() -> some View {
        guard let primaryIdea = viewModel.ideas.first else {
            return AnyView(EmptyView())
        }
        
        let score = viewModel.getBusinessGrowthScore(forIdea: primaryIdea)
        let ready = viewModel.getFounderReadiness(forIdea: primaryIdea)
        let exec = viewModel.getExecutionScore(forIdea: primaryIdea)
        
        return AnyView(
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("STARTUP GROWTH SCORE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                        Text(String(format: "%.1f%% Score", score))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(hex: "#BF5AF2"))
                    }
                    Spacer()
                }
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Founder Readiness:")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text(String(format: "%.0f%%", ready))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Execution Rating:")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text(String(format: "%.0f%%", exec))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(20)
            .background(Color(hex: "#1C1C1E"))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .padding(.top, 16)
        )
    }
    
    private func registerStartupSheet() -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)
                
                Text("Register New Startup")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    TextField("", text: $newTitle, prompt: Text("Startup Name").foregroundColor(.gray))
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    TextField("", text: $newMarket, prompt: Text("Target Customer Segment").foregroundColor(.gray))
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    Button("Save Startup Idea") {
                        viewModel.createNewIdea(title: newTitle, targetMarket: newMarket, forUser: userId)
                        newTitle = ""
                        newMarket = ""
                        showRegisterSheet = false
                    }
                    .font(.system(size: 17, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(!newTitle.isEmpty && !newMarket.isEmpty ? Color(hex: "#0A84FF") : Color.gray.opacity(0.2))
                    .foregroundColor(!newTitle.isEmpty && !newMarket.isEmpty ? .black : .gray)
                    .cornerRadius(12)
                    .disabled(newTitle.isEmpty || newMarket.isEmpty)
                }
                .padding(.horizontal, 20)
                Spacer()
            }
        }
    }
}
extension StartupIdea: Identifiable {}
