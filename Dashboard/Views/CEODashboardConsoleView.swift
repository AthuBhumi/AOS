import SwiftUI
import Models

public struct CEODashboardConsoleView: View {
    @State private var viewModel: CEODashboardViewModel
    private let userId: UUID
    
    @State private var aiAdvisorVM = AICEODecisionAdvisorViewModel()
    @State private var showExportSheet = false
    @State private var showQBRSheet = false
    @State private var csvText = ""
    
    @State private var showAddDecisionSheet = false
    @State private var decisionTitle = ""
    @State private var decisionOptions = ""
    
    public init(viewModel: CEODashboardViewModel, userId: UUID) {
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
                    Button("Retry") { viewModel.loadAllData(forUser: userId) }
                        .foregroundColor(Color(hex: "#0A84FF"))
                }
                
            case .loaded:
                ScrollView {
                    VStack(spacing: 24) {
                        // High level Ring indicator
                        overallScoreRingCard()
                        
                        // Metrics detail Grid
                        metricsGrid()
                        
                        // Finance Runway Overview
                        financeRunwayCard()
                        
                        // Decisions Queue Row
                        decisionsQueueCard()
                        
                        // Exporter / AI links
                        actionButtonsRow()
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            viewModel.loadAllData(forUser: userId)
        }
        .navigationTitle("CEO Command Console")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showExportSheet) {
            exportCSVSheet()
        }
        .sheet(isPresented: $showQBRSheet) {
            aiQBRSheet()
        }
        .sheet(isPresented: $showAddDecisionSheet) {
            addDecisionFormSheet()
        }
    }
    
    private func overallScoreRingCard() -> some View {
        VStack(spacing: 12) {
            Text("OVERALL EXECUTIVE SCORE")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
                .tracking(1.0)
            
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 12)
                    .frame(width: 140, height: 140)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(viewModel.overallScore / 100.0))
                    .stroke(Color(hex: "#30D158"), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text(String(format: "%.0f%%", viewModel.overallScore))
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    Text("PERFORMANCE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#1C1C1E"))
        .cornerRadius(16)
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private func metricsGrid() -> some View {
        let cols = [GridItem(.flexible()), GridItem(.flexible())]
        
        return LazyVGrid(columns: cols, spacing: 16) {
            gridItemView(title: "Founder Readiness", val: viewModel.founderReadiness, color: Color(hex: "#BF5AF2"))
            gridItemView(title: "Execution score", val: viewModel.executionScore, color: Color(hex: "#0A84FF"))
            gridItemView(title: "Corporate Leadership", val: viewModel.leadershipScore, color: Color(hex: "#FFD60A"))
            gridItemView(title: "Life Balance", val: viewModel.lifeBalanceScore, color: Color(hex: "#FF453A"))
        }
        .padding(.horizontal, 20)
    }
    
    private func gridItemView(title: String, val: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
            
            Text(String(format: "%.1f%%", val))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            ProgressView(value: val / 100.0)
                .accentColor(color)
        }
        .padding()
        .background(Color(hex: "#1C1C1E").opacity(0.8))
        .cornerRadius(12)
    }
    
    private func financeRunwayCard() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("FINANCIAL CAPACITIES")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
                .tracking(1.0)
                .padding(.leading, 8)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "$%.0f", viewModel.totalNetWorth))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    Text("Net Worth")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%.1f months", viewModel.runwayMonths))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(viewModel.runwayMonths < 6.0 ? Color(hex: "#FF453A") : Color(hex: "#30D158"))
                    Text("Reserves Runway")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(hex: "#1C1C1E").opacity(0.7))
            .cornerRadius(16)
        }
        .padding(.horizontal, 20)
    }
    
    private func decisionsQueueCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("HIGH PRIORITY DECISION QUEUE")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.gray)
                    .tracking(1.0)
                Spacer()
                Button("Add Decision") { showAddDecisionSheet = true }
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#0A84FF"))
            }
            .padding(.horizontal, 8)
            
            VStack(spacing: 12) {
                ForEach(viewModel.decisions) { decision in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(decision.title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            Spacer()
                            if decision.isResolved {
                                Text("Resolved")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(hex: "#30D158"))
                            }
                        }
                        
                        if !decision.isResolved {
                            let options = decision.optionsList.components(separatedBy: ",")
                            HStack(spacing: 10) {
                                ForEach(options, id: \.self) { opt in
                                    let cleanOpt = opt.trimmingCharacters(in: .whitespacesAndNewlines)
                                    Button(cleanOpt) {
                                        viewModel.resolveDecision(decisionId: decision.id, chosenOption: cleanOpt, forUser: userId)
                                    }
                                    .font(.system(size: 12, weight: .bold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.1))
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                                }
                            }
                        } else if let chosen = decision.chosenOption {
                            Text("Chosen Option: \(chosen)")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "#1C1C1E").opacity(0.7))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func actionButtonsRow() -> some View {
        HStack(spacing: 16) {
            Button("Generate QBR") {
                aiAdvisorVM.compileQuarterlyBusinessReview(
                    overall: viewModel.overallScore,
                    readiness: viewModel.founderReadiness,
                    exec: viewModel.executionScore,
                    leadership: viewModel.leadershipScore,
                    balance: viewModel.lifeBalanceScore,
                    runway: viewModel.runwayMonths
                )
                showQBRSheet = true
            }
            .font(.system(size: 15, weight: .bold))
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(hex: "#BF5AF2"))
            .foregroundColor(.black)
            .cornerRadius(12)
            
            Button("Export CSV") {
                csvText = viewModel.compileCEOCSVReport()
                showExportSheet = true
            }
            .font(.system(size: 15, weight: .bold))
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(hex: "#30D158"))
            .foregroundColor(.black)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Sheets
    private func exportCSVSheet() -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)
                
                Text("Export CEO Data Sheet")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                ScrollView {
                    Text(csvText)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                Button("Copy Sheet Data") {
                    UIPasteboard.general.string = csvText
                    showExportSheet = false
                }
                .font(.system(size: 17, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#30D158"))
                .foregroundColor(.black)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }
    
    private func aiQBRSheet() -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)
                
                Text("QBR Executive Report")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                ScrollView {
                    Text(aiAdvisorVM.reportText)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                Button("Dismiss") {
                    showQBRSheet = false
                }
                .font(.system(size: 17, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#BF5AF2"))
                .foregroundColor(.black)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }
    
    private func addDecisionFormSheet() -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)
                
                Text("Log High-Priority Choice")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    TextField("", text: $decisionTitle, prompt: Text("Decision title / description").foregroundColor(.gray))
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    TextField("", text: $decisionOptions, prompt: Text("Options (comma separated, e.g. Yes, No)").foregroundColor(.gray))
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    Button("Save Decision item") {
                        viewModel.addNewDecision(title: decisionTitle, options: decisionOptions, forUser: userId)
                        decisionTitle = ""
                        decisionOptions = ""
                        showAddDecisionSheet = false
                    }
                    .font(.system(size: 17, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(!decisionTitle.isEmpty && !decisionOptions.isEmpty ? Color(hex: "#0A84FF") : Color.gray.opacity(0.2))
                    .foregroundColor(!decisionTitle.isEmpty && !decisionOptions.isEmpty ? .black : .gray)
                    .cornerRadius(12)
                    .disabled(decisionTitle.isEmpty || decisionOptions.isEmpty)
                }
                .padding(.horizontal, 20)
                Spacer()
            }
        }
    }
}
extension CEODecision: Identifiable {}
