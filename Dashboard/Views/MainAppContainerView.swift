import SwiftUI
import Models
import Repositories
import AI
import Coding
import Reading
import Journal
import Habits
import Goals
import Finance
import Business
import Networking
import Storage

public struct MainAppContainerView: View {
    private let userId: UUID
    
    // Dependencies
    private let userRepo: UserRepositoryProtocol
    private let missionRepo: MissionRepositoryProtocol
    private let chatRepo: ChatMessageRepositoryProtocol
    private let typingRepo: TypingRepositoryProtocol
    private let readingRepo: ReadingRepositoryProtocol
    private let journalRepo: JournalRepositoryProtocol
    private let habitRepo: HabitRepositoryProtocol
    private let goalRepo: GoalRepositoryProtocol
    private let financeRepo: AdvancedFinanceRepositoryProtocol
    private let businessRepo: BusinessBuilderRepositoryProtocol
    private let companyRepo: CompanyBuilderRepositoryProtocol
    private let decisionRepo: CEODecisionRepositoryProtocol
    private let apiClient: APIClient
    private let aiService: AIMentorServiceProtocol
    
    @State private var selectedTab = 0
    
    public init(
        userId: UUID,
        userRepo: UserRepositoryProtocol,
        missionRepo: MissionRepositoryProtocol,
        chatRepo: ChatMessageRepositoryProtocol,
        typingRepo: TypingRepositoryProtocol,
        readingRepo: ReadingRepositoryProtocol,
        journalRepo: JournalRepositoryProtocol,
        habitRepo: HabitRepositoryProtocol,
        goalRepo: GoalRepositoryProtocol,
        financeRepo: AdvancedFinanceRepositoryProtocol,
        businessRepo: BusinessBuilderRepositoryProtocol,
        companyRepo: CompanyBuilderRepositoryProtocol,
        decisionRepo: CEODecisionRepositoryProtocol,
        apiClient: APIClient,
        aiService: AIMentorServiceProtocol
    ) {
        self.userId = userId
        self.userRepo = userRepo
        self.missionRepo = missionRepo
        self.chatRepo = chatRepo
        self.typingRepo = typingRepo
        self.readingRepo = readingRepo
        self.journalRepo = journalRepo
        self.habitRepo = habitRepo
        self.goalRepo = goalRepo
        self.financeRepo = financeRepo
        self.businessRepo = businessRepo
        self.companyRepo = companyRepo
        self.decisionRepo = decisionRepo
        self.apiClient = apiClient
        self.aiService = aiService
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Dashboard Console
            NavigationStack {
                DashboardConsoleView(
                    viewModel: DashboardViewModel(userRepository: userRepo, missionRepository: missionRepo),
                    userId: userId
                )
            }
            .tabItem {
                Label("Console", systemImage: "terminal.fill")
            }
            .tag(0)
            
            // Tab 2: AI Mentor
            NavigationStack {
                AIMentorView(
                    viewModel: AIMentorViewModel(
                        aiService: aiService,
                        chatRepository: chatRepo,
                        userRepository: userRepo,
                        typingRepository: typingRepo,
                        readingRepository: readingRepo,
                        financeRepository: financeRepo,
                        businessRepository: businessRepo
                    ),
                    userId: userId
                )
            }
            .tabItem {
                Label("Mentor", systemImage: "brain.head.profile")
            }
            .tag(1)
            
            // Tab 3: Coding Academy
            NavigationStack {
                CodingAcademyView(
                    viewModel: CodingAcademyViewModel(apiClient: apiClient),
                    userRepository: userRepo,
                    userId: userId
                )
            }
            .tabItem {
                Label("Academy", systemImage: "laptopcomputer")
            }
            .tag(2)
            
            // Tab 4: Routines (Habits, Goals, Reading, Journal)
            NavigationStack {
                routinesMenu()
            }
            .tabItem {
                Label("Routines", systemImage: "calendar.badge.clock")
            }
            .tag(3)
            
            // Tab 5: Venture (Finance, Lean Canvas)
            NavigationStack {
                ventureMenu()
            }
            .tabItem {
                Label("Venture", systemImage: "briefcase.fill")
            }
            .tag(4)
        }
        .accentColor(Color(hex: "#0A84FF"))
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Sub-Navigators
    private func routinesMenu() -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Developer Routines")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 24)
                
                VStack(spacing: 16) {
                    NavigationLink(destination: HabitListView(viewModel: HabitViewModel(habitRepository: habitRepo, userRepository: userRepo), userId: userId)) {
                        menuRow(title: "Atomic Habit Stacks", descr: "Track streaks compliance", icon: "flame.fill", color: Color(hex: "#FFD60A"))
                    }
                    
                    NavigationLink(destination: GoalListView(viewModel: GoalViewModel(goalRepository: goalRepo, userRepository: userRepo), userId: userId)) {
                        menuRow(title: "OKR Career Goals", descr: "Align objectives with progression", icon: "scope", color: Color(hex: "#BF5AF2"))
                    }
                    
                    NavigationLink(destination: BookListView(viewModel: ReadingViewModel(readingRepository: readingRepo, userRepository: userRepo), userId: userId)) {
                        menuRow(title: "Reading & Active Recall", descr: "Retain books content via SM-2", icon: "book.closed.fill", color: Color(hex: "#30D158"))
                    }
                    
                    NavigationLink(destination: JournalListView(viewModel: JournalViewModel(journalRepository: journalRepo, userRepository: userRepo), userId: userId)) {
                        menuRow(title: "Reflection CBT Journals", descr: "Reframe cognitive distortions", icon: "pencil.and.outline", color: Color(hex: "#0A84FF"))
                    }
                    
                    NavigationLink(destination: TypingTrainerView(viewModel: TypingTrainerViewModel(typingRepository: typingRepo, userRepository: userRepo), userId: userId, activeStage: 1)) {
                        menuRow(title: "Typing Speed Drills", descr: "Build muscle memory", icon: "keyboard", color: .white)
                    }
                }
                .padding(.horizontal, 20)
                Spacer()
            }
        }
    }
    
    private func ventureMenu() -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Venture Validation")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 24)
                
                VStack(spacing: 16) {
                    NavigationLink(destination: AdvancedFinanceDashboardView(viewModel: AdvancedFinanceViewModel(financeRepository: financeRepo, userRepository: userRepo), userId: userId)) {
                        menuRow(title: "Capital Runway Ledger", descr: "Track burn rate and survival runway", icon: "banknote.fill", color: Color(hex: "#30D158"))
                    }
                    
                    NavigationLink(destination: BusinessBuilderDashboardView(viewModel: BusinessBuilderViewModel(businessRepo: businessRepo, userRepository: userRepo), userId: userId)) {
                        menuRow(title: "Startup Lean Canvas", descr: "Map assumptions validation", icon: "square.grid.3x3.fill", color: Color(hex: "#0A84FF"))
                    }
                    
                    NavigationLink(destination: CompanyBuilderDashboardView(viewModel: CompanyBuilderViewModel(companyRepo: companyRepo, userRepository: userRepo), userId: userId)) {
                        menuRow(title: "Enterprise Company Builder", descr: "Manage teams payroll and kanban boards", icon: "building.2.fill", color: Color(hex: "#30D158"))
                    }
                    
                    NavigationLink(destination: CEODashboardConsoleView(viewModel: CEODashboardViewModel(decisionRepo: decisionRepo, userRepo: userRepo, companyRepo: companyRepo, businessRepo: businessRepo, financeRepo: financeRepo, habitRepo: habitRepo, goalRepo: goalRepo), userId: userId)) {
                        menuRow(title: "CEO Command Console", descr: "Aggregated performance overview & decisions", icon: "crown.fill", color: Color(hex: "#FFD60A"))
                    }
                }
                .padding(.horizontal, 20)
                Spacer()
            }
        }
    }
    
    private func menuRow(title: String, descr: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text(descr)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(hex: "#1C1C1E"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}
