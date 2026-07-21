import SwiftUI
import Models

public struct StartupIdeaDetailView: View {
    @Bindable private var viewModel: BusinessBuilderViewModel
    let idea: StartupIdea
    private let userId: UUID
    
    @State private var selectedTab = 0
    @State private var swotAdviceVM = AIBusinessMentorViewModel()
    
    // Form variables
    @State private var newMilestoneTitle = ""
    @State private var deckTitle = ""
    @State private var deckUrl = ""
    @State private var askAmount = ""
    @State private var equity = ""
    
    @State private var riskDescr = ""
    @State private var riskImpact = 3
    @State private var riskProb = 3
    @State private var riskMitigation = ""
    
    public init(viewModel: BusinessBuilderViewModel, idea: StartupIdea, userId: UUID) {
        self.viewModel = viewModel
        self.idea = idea
        self.userId = userId
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Tab Selector
            Picker("", selection: $selectedTab) {
                Text("Canvas").tag(0)
                Text("SWOT").tag(1)
                Text("Roadmap").tag(2)
                Text("Legal").tag(3)
                Text("Pitch & Risk").tag(4)
                Text("AI").tag(5)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(Color.black)
            
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        switch selectedTab {
                        case 0:
                            canvasTab()
                        case 1:
                            swotTab()
                        case 2:
                            roadmapTab()
                        case 3:
                            legalTab()
                        case 4:
                            pitchAndRiskTab()
                        default:
                            aiAdvisorTab()
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle(idea.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Tab Views
    private func canvasTab() -> some View {
        VStack(spacing: 16) {
            sectionHeader("Lean Canvas Canvas")
            
            boxEditor(title: "Problem", text: $viewModel.ideas[0].problem)
            boxEditor(title: "Solution", text: $viewModel.ideas[0].solution)
            boxEditor(title: "Unique Value Proposition", text: $viewModel.ideas[0].uniqueValueProp)
            boxEditor(title: "Unfair Advantage", text: $viewModel.ideas[0].unfairAdvantage)
            boxEditor(title: "Customer Segments", text: $viewModel.ideas[0].customerSegments)
            
            Button("Save Canvas") {
                viewModel.commitIdeaDetails(idea: idea, forUser: userId)
            }
            .font(.system(size: 17, weight: .bold))
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(hex: "#0A84FF"))
            .foregroundColor(.black)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
    }
    
    private func swotTab() -> some View {
        VStack(spacing: 16) {
            sectionHeader("SWOT & Competitor Profiles")
            
            boxEditor(title: "Strengths", text: $viewModel.ideas[0].swotStrengths)
            boxEditor(title: "Weaknesses", text: $viewModel.ideas[0].swotWeaknesses)
            boxEditor(title: "Opportunities", text: $viewModel.ideas[0].swotOpportunities)
            boxEditor(title: "Threats", text: $viewModel.ideas[0].swotThreats)
            
            boxEditor(title: "Competitors List", text: $viewModel.ideas[0].competitorsList)
            
            Button("Save SWOT & Competitors") {
                viewModel.commitIdeaDetails(idea: idea, forUser: userId)
            }
            .font(.system(size: 17, weight: .bold))
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(hex: "#0A84FF"))
            .foregroundColor(.black)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
    }
    
    private func roadmapTab() -> some View {
        VStack(spacing: 16) {
            sectionHeader("Product Roadmap")
            
            // Add Milestone Form
            VStack(spacing: 12) {
                TextField("", text: $newMilestoneTitle, prompt: Text("New Milestone Title").foregroundColor(.gray))
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                
                Button("Add Milestone") {
                    let m = StartupMilestone(title: newMilestoneTitle, isCompleted: false, startupIdea: idea)
                    idea.milestones.append(m)
                    viewModel.commitIdeaDetails(idea: idea, forUser: userId)
                    newMilestoneTitle = ""
                }
                .disabled(newMilestoneTitle.isEmpty)
            }
            .padding()
            .background(Color(hex: "#1C1C1E"))
            .cornerRadius(16)
            
            // Milestones lists
            VStack(spacing: 10) {
                ForEach(idea.milestones) { m in
                    HStack {
                        Button(action: {
                            viewModel.toggleMilestone(ideaId: idea.id, milestoneId: m.id, forUser: userId)
                        }) {
                            Image(systemName: m.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(m.isCompleted ? Color(hex: "#30D158") : .gray)
                        }
                        
                        Text(m.title)
                            .foregroundColor(m.isCompleted ? .gray : .white)
                            .strikethrough(m.isCompleted)
                        Spacer()
                    }
                    .padding()
                    .background(Color(hex: "#1C1C1E").opacity(0.7))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func legalTab() -> some View {
        VStack(spacing: 16) {
            sectionHeader("Regulatory Compliance Checklist")
            
            VStack(spacing: 12) {
                ForEach(idea.complianceItems) { item in
                    HStack {
                        Button(action: {
                            viewModel.toggleCompliance(ideaId: idea.id, itemId: item.id, forUser: userId)
                        }) {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.isCompleted ? Color(hex: "#30D158") : .gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.itemText)
                                .foregroundColor(.white)
                            Text(item.category)
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(hex: "#1C1C1E").opacity(0.7))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func pitchAndRiskTab() -> some View {
        VStack(spacing: 16) {
            sectionHeader("Investor Pitch & Risk Register")
            
            // Add Pitch Deck Form
            VStack(spacing: 12) {
                TextField("", text: $deckTitle, prompt: Text("Pitch Title (e.g. Seed Deck)").foregroundColor(.gray))
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                
                TextField("", text: $deckUrl, prompt: Text("Deck Link / URL").foregroundColor(.gray))
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    TextField("", text: $askAmount, prompt: Text("Ask ($)").foregroundColor(.gray))
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    TextField("", text: $equity, prompt: Text("Equity (%)").foregroundColor(.gray))
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
                
                Button("Save Pitch Deck") {
                    if let value = Double(askAmount), let eq = Double(equity) {
                        let deck = PitchDeck(title: deckTitle, deckUrl: deckUrl, askAmount: value, equityPercent: eq, startupIdea: idea)
                        idea.pitchDecks.append(deck)
                        viewModel.commitIdeaDetails(idea: idea, forUser: userId)
                        deckTitle = ""
                        deckUrl = ""
                        askAmount = ""
                        equity = ""
                    }
                }
                .disabled(deckTitle.isEmpty || askAmount.isEmpty)
            }
            .padding()
            .background(Color(hex: "#1C1C1E"))
            .cornerRadius(16)
            
            // Add Risk Form
            VStack(spacing: 12) {
                TextField("", text: $riskDescr, prompt: Text("Risk description").foregroundColor(.gray))
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                
                HStack {
                    Text("Impact: \(riskImpact)")
                        .foregroundColor(.gray)
                    Slider(value: Binding(get: { Double(riskImpact) }, set: { riskImpact = Int($0) }), in: 1.0...5.0, step: 1.0)
                }
                
                HStack {
                    Text("Prob: \(riskProb)")
                        .foregroundColor(.gray)
                    Slider(value: Binding(get: { Double(riskProb) }, set: { riskProb = Int($0) }), in: 1.0...5.0, step: 1.0)
                }
                
                TextField("", text: $riskMitigation, prompt: Text("Mitigation strategy").foregroundColor(.gray))
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                
                Button("Log Risk") {
                    let risk = RiskRegistration(descr: riskDescr, impact: riskImpact, probability: riskProb, mitigation: riskMitigation, startupIdea: idea)
                    idea.risks.append(risk)
                    viewModel.commitIdeaDetails(idea: idea, forUser: userId)
                    riskDescr = ""
                    riskMitigation = ""
                }
                .disabled(riskDescr.isEmpty)
            }
            .padding()
            .background(Color(hex: "#1C1C1E"))
            .cornerRadius(16)
        }
        .padding(.horizontal, 20)
    }
    
    private func aiAdvisorTab() -> some View {
        VStack(spacing: 16) {
            sectionHeader("AI Business Mentor")
            
            Button("Compile Weekly Founder Report") {
                swotAdviceVM.compileWeeklyFounderReport(
                    forIdea: idea,
                    growthScore: viewModel.getBusinessGrowthScore(forIdea: idea),
                    readinessScore: viewModel.getFounderReadiness(forIdea: idea),
                    riskScore: viewModel.getRiskScore(forIdea: idea)
                )
            }
            .font(.system(size: 17, weight: .bold))
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(hex: "#BF5AF2"))
            .foregroundColor(.black)
            .cornerRadius(12)
            
            if !swotAdviceVM.weeklyReportText.isEmpty {
                Text(swotAdviceVM.weeklyReportText)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Sub Helpers
    private func sectionHeader(_ text: String) -> some View {
        HStack {
            Text(text.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
                .tracking(1.0)
            Spacer()
        }
        .padding(.top, 12)
    }
    
    private func boxEditor(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
            
            TextEditor(text: text)
                .frame(height: 90)
                .padding(8)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .foregroundColor(.white)
        }
    }
}
extension StartupMilestone: Identifiable {}
extension ComplianceItem: Identifiable {}
extension PitchDeck: Identifiable {}
extension RiskRegistration: Identifiable {}
