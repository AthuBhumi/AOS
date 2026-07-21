import SwiftUI
import Models

public struct HabitListView: View {
    @State private var viewModel: HabitViewModel
    private let userId: UUID
    @State private var showAddSheet = false
    
    public init(viewModel: HabitViewModel, userId: UUID) {
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
                    Button("Retry") { viewModel.loadHabits(forUser: userId) }
                        .foregroundColor(Color(hex: "#0A84FF"))
                }
                
            case .loaded(let habits):
                VStack(spacing: 20) {
                    if habits.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "checklist")
                                .font(.system(size: 44))
                                .foregroundColor(.gray)
                            Text("No habits tracked yet.")
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 80)
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(habits) { habit in
                                    HStack {
                                        // Streak Icon Badge
                                        VStack {
                                            Image(systemName: "flame.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(habit.activeStreak > 0 ? Color(hex: "#FFD60A") : .gray)
                                            Text("\(habit.activeStreak) d")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                        .frame(width: 44)
                                        
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(habit.title)
                                                .font(.system(size: 17, weight: .bold))
                                                .foregroundColor(.white)
                                            
                                            // Compliance percentage
                                            let rate = viewModel.getComplianceRate(habit)
                                            Text(String(format: "30-day compliance: %.0f%%", rate))
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.leading, 8)
                                        Spacer()
                                        
                                        // Completion checkbox action
                                        let isCompletedToday = habit.completionHistory.contains(Calendar.current.startOfDay(for: Date()))
                                        
                                        Button(action: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                viewModel.checkOffHabit(habitId: habit.id, forUser: userId) { _ in }
                                            }
                                        }) {
                                            Image(systemName: isCompletedToday ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 28))
                                                .foregroundColor(isCompletedToday ? Color(hex: "#30D158") : .gray)
                                        }
                                        .disabled(isCompletedToday)
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
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadHabits(forUser: userId)
        }
        .navigationTitle("Habit Stacks")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddHabitView(viewModel: viewModel, userId: userId)
        }
    }
}
extension Habit: Identifiable {}
