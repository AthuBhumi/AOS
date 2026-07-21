import SwiftUI
import SwiftData

@main
struct ATHARVAOSApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                AOSRootView()
            }
            .preferredColorScheme(.dark)
        }
    }
}

struct AOSRootView: View {
    @State private var isReady = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isReady {
                AOSMainTabView()
            } else {
                // Splash screen
                VStack(spacing: 20) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 72))
                        .foregroundColor(Color(red: 0.04, green: 0.52, blue: 1.0))

                    Text("ATHARVA OS")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Text("Developer Operating System")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.top, 12)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isReady = true
                }
            }
        }
    }
}

struct AOSMainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Dashboard
            NavigationStack {
                AOSDemoDashboardView()
            }
            .tabItem { Label("Console", systemImage: "terminal.fill") }
            .tag(0)

            // Tab 2: Finance
            NavigationStack {
                AOSDemoFinanceView()
            }
            .tabItem { Label("Finance", systemImage: "banknote.fill") }
            .tag(1)

            // Tab 3: Business
            NavigationStack {
                AOSDemoBusinessView()
            }
            .tabItem { Label("Venture", systemImage: "briefcase.fill") }
            .tag(2)

            // Tab 4: Routines
            NavigationStack {
                AOSDemoRoutinesView()
            }
            .tabItem { Label("Routines", systemImage: "calendar.badge.clock") }
            .tag(3)

            // Tab 5: CEO
            NavigationStack {
                AOSDemoCEOView()
            }
            .tabItem { Label("CEO", systemImage: "crown.fill") }
            .tag(4)
        }
        .accentColor(Color(red: 0.04, green: 0.52, blue: 1.0))
    }
}

// MARK: - Demo Dashboard
struct AOSDemoDashboardView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    // XP Card
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("LEVEL 7 DEVELOPER")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.gray)
                                Text("2,450 XP")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(Color(red: 0.04, green: 0.52, blue: 1.0))
                        }
                        ProgressView(value: 0.65)
                            .accentColor(Color(red: 0.04, green: 0.52, blue: 1.0))
                    }
                    .padding(20)
                    .background(Color(white: 0.11))
                    .cornerRadius(16)

                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        statCard(title: "INT", value: "4", icon: "brain", color: .purple)
                        statCard(title: "STR", value: "3", icon: "bolt.fill", color: .orange)
                        statCard(title: "CHA", value: "5", icon: "star.fill", color: .yellow)
                        statCard(title: "FOR", value: "4", icon: "shield.fill", color: .green)
                    }

                    // Daily Missions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DAILY MISSIONS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                        missionRow(title: "Complete 1 coding challenge", xp: 50, done: true)
                        missionRow(title: "Log 30 min typing drill", xp: 30, done: false)
                        missionRow(title: "Journal entry for today", xp: 20, done: false)
                    }
                    .padding(20)
                    .background(Color(white: 0.11))
                    .cornerRadius(16)
                }
                .padding(20)
            }
        }
        .navigationTitle("Command Console")
        .navigationBarTitleDisplayMode(.inline)
    }

    func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(white: 0.11))
        .cornerRadius(12)
    }

    func missionRow(title: String, xp: Int, done: Bool) -> some View {
        HStack {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundColor(done ? .green : .gray)
            Text(title)
                .foregroundColor(done ? .gray : .white)
                .strikethrough(done)
            Spacer()
            Text("+\(xp) XP")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(red: 0.04, green: 0.52, blue: 1.0))
        }
    }
}

// MARK: - Demo Finance
struct AOSDemoFinanceView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    // Net Worth
                    VStack(spacing: 6) {
                        Text("NET WORTH")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                        Text("$67,850")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                        HStack(spacing: 20) {
                            Text("Cash: $15,500")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                            Text("Assets: $52,350")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color(white: 0.11))
                    .cornerRadius(16)

                    // Runway Gauge
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 10)
                                .frame(width: 130, height: 130)
                            Circle()
                                .trim(from: 0, to: 0.7)
                                .stroke(Color.green, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                .frame(width: 130, height: 130)
                                .rotationEffect(.degrees(-90))
                            VStack {
                                Text("8.4")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Months Runway")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                            }
                        }
                        HStack(spacing: 40) {
                            VStack(spacing: 4) {
                                Text("$1,850")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("Monthly Burn")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            VStack(spacing: 4) {
                                Text("$15,500")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("Cash Reserves")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(white: 0.11).opacity(0.7))
                    .cornerRadius(16)

                    // Transactions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("RECENT TRANSACTIONS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                        txRow(title: "Salary", amount: "+$4,500", cat: "Income", positive: true)
                        txRow(title: "Co-working Rent", amount: "-$1,500", cat: "Fixed", positive: false)
                        txRow(title: "AWS Hosting", amount: "-$350", cat: "Variable", positive: false)
                    }
                    .padding(20)
                    .background(Color(white: 0.11))
                    .cornerRadius(16)
                }
                .padding(20)
            }
        }
        .navigationTitle("Capital Engine")
        .navigationBarTitleDisplayMode(.inline)
    }

    func txRow(title: String, amount: String, cat: String, positive: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).foregroundColor(.white).font(.system(size: 15, weight: .semibold))
                Text(cat).foregroundColor(.gray).font(.system(size: 12))
            }
            Spacer()
            Text(amount)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(positive ? .green : .white)
        }
    }
}

// MARK: - Demo Business
struct AOSDemoBusinessView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    // Growth Score
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("STARTUP GROWTH SCORE")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.gray)
                                Text("72.5%")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.purple)
                            }
                            Spacer()
                        }
                        HStack(spacing: 20) {
                            VStack(alignment: .leading) {
                                Text("Founder Readiness:").font(.system(size: 12)).foregroundColor(.gray)
                                Text("68%").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Execution:").font(.system(size: 12)).foregroundColor(.gray)
                                Text("75%").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(white: 0.11))
                    .cornerRadius(16)

                    // Venture
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ATHARVA OS")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                        Text("Market: Indie Hackers & Developers")
                            .font(.system(size: 13)).foregroundColor(.gray)
                        ProgressView(value: 0.725)
                            .accentColor(.purple)
                    }
                    .padding(20)
                    .background(Color(white: 0.11).opacity(0.7))
                    .cornerRadius(16)

                    // Milestones
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PRODUCT ROADMAP")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                        milestoneRow(title: "Build local SwiftData container", done: true)
                        milestoneRow(title: "Set up SQLCipher encryption", done: false)
                        milestoneRow(title: "Launch beta landing page", done: false)
                    }
                    .padding(20)
                    .background(Color(white: 0.11))
                    .cornerRadius(16)

                    // Company Health
                    VStack(alignment: .leading, spacing: 12) {
                        Text("COMPANY HEALTH")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                        HStack {
                            VStack(alignment: .leading) {
                                Text("59.0%").font(.system(size: 20, weight: .bold)).foregroundColor(.green)
                                Text("Health Score").font(.system(size: 12)).foregroundColor(.gray)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("78.2%").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                                Text("Profit Margin").font(.system(size: 12)).foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(white: 0.11))
                    .cornerRadius(16)
                }
                .padding(20)
            }
        }
        .navigationTitle("Business Builder")
        .navigationBarTitleDisplayMode(.inline)
    }

    func milestoneRow(title: String, done: Bool) -> some View {
        HStack {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundColor(done ? .green : .gray)
            Text(title)
                .foregroundColor(done ? .gray : .white)
                .strikethrough(done)
            Spacer()
        }
    }
}

// MARK: - Demo Routines
struct AOSDemoRoutinesView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    // Habits
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ATOMIC HABITS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                        habitRow(name: "Morning Meditation", streak: 14, emoji: "🧘")
                        habitRow(name: "Read 30 Pages", streak: 8, emoji: "📖")
                        habitRow(name: "Gym Workout", streak: 5, emoji: "💪")
                        habitRow(name: "Code 2 Hours", streak: 21, emoji: "💻")
                    }
                    .padding(20)
                    .background(Color(white: 0.11))
                    .cornerRadius(16)

                    // Goals
                    VStack(alignment: .leading, spacing: 12) {
                        Text("OKR GOALS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                        goalRow(title: "Ship ATHARVA OS v1.0", progress: 0.45)
                        goalRow(title: "Reach 500 GitHub Stars", progress: 0.12)
                        goalRow(title: "Complete System Design Book", progress: 0.78)
                    }
                    .padding(20)
                    .background(Color(white: 0.11))
                    .cornerRadius(16)

                    // Reading
                    VStack(alignment: .leading, spacing: 12) {
                        Text("READING LIST")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                        bookRow(title: "Atomic Habits", author: "James Clear", pages: "240/320")
                        bookRow(title: "Zero to One", author: "Peter Thiel", pages: "80/224")
                    }
                    .padding(20)
                    .background(Color(white: 0.11))
                    .cornerRadius(16)

                    // Journal
                    VStack(alignment: .leading, spacing: 12) {
                        Text("JOURNAL ENTRIES")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                        journalRow(title: "Productive sprint day", mood: "😊", date: "Today")
                        journalRow(title: "Debugged SwiftData issue", mood: "🔥", date: "Yesterday")
                    }
                    .padding(20)
                    .background(Color(white: 0.11))
                    .cornerRadius(16)
                }
                .padding(20)
            }
        }
        .navigationTitle("Developer Routines")
        .navigationBarTitleDisplayMode(.inline)
    }

    func habitRow(name: String, streak: Int, emoji: String) -> some View {
        HStack {
            Text(emoji)
            Text(name).foregroundColor(.white)
            Spacer()
            Text("\(streak) 🔥")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.orange)
        }
    }

    func goalRow(title: String, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).foregroundColor(.white).font(.system(size: 14))
                Spacer()
                Text("\(Int(progress * 100))%").foregroundColor(.gray).font(.system(size: 12, weight: .bold))
            }
            ProgressView(value: progress).accentColor(.purple)
        }
    }

    func bookRow(title: String, author: String, pages: String) -> some View {
        HStack {
            Image(systemName: "book.closed.fill").foregroundColor(.green)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).foregroundColor(.white).font(.system(size: 14, weight: .semibold))
                Text(author).foregroundColor(.gray).font(.system(size: 12))
            }
            Spacer()
            Text(pages).foregroundColor(.gray).font(.system(size: 12))
        }
    }

    func journalRow(title: String, mood: String, date: String) -> some View {
        HStack {
            Text(mood)
            Text(title).foregroundColor(.white).font(.system(size: 14))
            Spacer()
            Text(date).foregroundColor(.gray).font(.system(size: 11))
        }
    }
}

// MARK: - Demo CEO
struct AOSDemoCEOView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    // Overall Score Ring
                    VStack(spacing: 12) {
                        Text("OVERALL EXECUTIVE SCORE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 12)
                                .frame(width: 140, height: 140)
                            Circle()
                                .trim(from: 0, to: 0.68)
                                .stroke(Color.green, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                .frame(width: 140, height: 140)
                                .rotationEffect(.degrees(-90))
                            VStack {
                                Text("68%")
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
                    .background(Color(white: 0.11))
                    .cornerRadius(16)

                    // KPI Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        kpiCard(title: "FOUNDER READINESS", val: "72.5%", color: .purple)
                        kpiCard(title: "EXECUTION", val: "65.0%", color: Color(red: 0.04, green: 0.52, blue: 1.0))
                        kpiCard(title: "LEADERSHIP", val: "70.8%", color: .yellow)
                        kpiCard(title: "LIFE BALANCE", val: "80.0%", color: .red)
                    }

                    // Decisions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("HIGH PRIORITY DECISIONS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                        decisionRow(title: "Approve marketing budget reallocation", options: ["Approve", "Delay"])
                        decisionRow(title: "Hire junior Swift developer", options: ["Hire", "Wait"])
                    }
                    .padding(20)
                    .background(Color(white: 0.11))
                    .cornerRadius(16)

                    // Finance Summary
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("$67,850")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                            Text("Net Worth")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("8.4 months")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.green)
                            Text("Runway")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(20)
                    .background(Color(white: 0.11).opacity(0.7))
                    .cornerRadius(16)
                }
                .padding(20)
            }
        }
        .navigationTitle("CEO Command Console")
        .navigationBarTitleDisplayMode(.inline)
    }

    func kpiCard(title: String, val: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
            Text(val)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(white: 0.11).opacity(0.8))
        .cornerRadius(12)
    }

    func decisionRow(title: String, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            HStack(spacing: 10) {
                ForEach(options, id: \.self) { opt in
                    Button(opt) {}
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.1))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(white: 0.11).opacity(0.7))
        .cornerRadius(12)
    }
}
