import SwiftUI
import Models

public struct CompanyBuilderDashboardView: View {
    @State private var viewModel: CompanyBuilderViewModel
    private let userId: UUID
    @State private var showRegisterSheet = false
    @State private var newCompanyName = ""
    
    public init(viewModel: CompanyBuilderViewModel, userId: UUID) {
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
                    Button("Retry") { viewModel.loadCompanies(forUser: userId) }
                        .foregroundColor(Color(hex: "#0A84FF"))
                }
                
            case .loaded:
                ScrollView {
                    VStack(spacing: 24) {
                        // Corporate health summary
                        healthStatsOverview()
                        
                        // Active companies list
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ENTERPRISE LIST")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1.0)
                                .padding(.leading, 8)
                            
                            ForEach(viewModel.companies) { company in
                                NavigationLink(destination: CompanyDetailView(viewModel: viewModel, company: company, userId: userId)) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(company.name)
                                                .font(.system(size: 17, weight: .bold))
                                                .foregroundColor(.white)
                                            Text("\(company.employees.count) Employees • \(company.projects.count) Sprint Tasks")
                                                .font(.system(size: 13))
                                                .foregroundColor(.gray)
                                            
                                            // Progress bar
                                            let progress = viewModel.getProjectProgress(forCompany: company)
                                            ProgressView(value: progress / 100.0)
                                                .accentColor(Color(hex: "#30D158"))
                                                .scaleEffect(x: 1, y: 1.2, anchor: .leading)
                                                .padding(.top, 4)
                                        }
                                        Spacer()
                                        
                                        let health = viewModel.getCompanyHealthScore(forCompany: company)
                                        Text(String(format: "%.0f%% Health", health))
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
            viewModel.loadCompanies(forUser: userId)
        }
        .navigationTitle("Company Builder")
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
            registerCompanySheet()
        }
    }
    
    private func healthStatsOverview() -> some View {
        guard let primaryCompany = viewModel.companies.first else {
            return AnyView(EmptyView())
        }
        
        let health = viewModel.getCompanyHealthScore(forCompany: primaryCompany)
        let profit = viewModel.getProfitMargin(forCompany: primaryCompany)
        let attendance = viewModel.getEmployeeProductivity(forCompany: primaryCompany)
        
        return AnyView(
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CORPORATE HEALTH SCORE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                        Text(String(format: "%.1f%% Health", health))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(hex: "#30D158"))
                    }
                    Spacer()
                }
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Profit Margin:")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text(String(format: "%.1f%%", profit))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Attendance compliance:")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text(String(format: "%.1f%%", attendance))
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
    
    private func registerCompanySheet() -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)
                
                Text("Register Corporate Entity")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    TextField("", text: $newCompanyName, prompt: Text("Company Name (Pvt Ltd / LLC)").foregroundColor(.gray))
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    Button("Save Corporate Entity") {
                        viewModel.createNewCompany(name: newCompanyName, forUser: userId)
                        newCompanyName = ""
                        showRegisterSheet = false
                    }
                    .font(.system(size: 17, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(!newCompanyName.isEmpty ? Color(hex: "#0A84FF") : Color.gray.opacity(0.2))
                    .foregroundColor(!newCompanyName.isEmpty ? .black : .gray)
                    .cornerRadius(12)
                    .disabled(newCompanyName.isEmpty)
                }
                .padding(.horizontal, 20)
                Spacer()
            }
        }
    }
}
extension Company: Identifiable {}
