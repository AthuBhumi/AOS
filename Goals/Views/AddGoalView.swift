import SwiftUI

public struct AddGoalView: View {
    @Bindable private var viewModel: GoalViewModel
    private let userId: UUID
    @Environment(\.dismiss) private var dismiss
    
    @State private var goalTitle = ""
    @State private var category = "Skill"
    @State private var targetDate = Date().addingTimeInterval(86400 * 30)
    
    @State private var kr1 = ""
    @State private var kr2 = ""
    @State private var kr3 = ""
    
    public init(viewModel: GoalViewModel, userId: UUID) {
        self.viewModel = viewModel
        self.userId = userId
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    Capsule()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 36, height: 5)
                        .padding(.top, 12)
                    
                    Text("Establish New OKR")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 16) {
                        // Title
                        TextField("", text: $goalTitle, prompt: Text("Objective Title").foregroundColor(.gray))
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                        
                        // Category Picker
                        Picker("", selection: $category) {
                            Text("Skill").tag("Skill")
                            Text("Career").tag("Career")
                            Text("Personal").tag("Personal")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        // Target Date
                        DatePicker("Target Date", selection: $targetDate, displayedComponents: .date)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        
                        // Key Results Input list
                        VStack(alignment: .leading, spacing: 10) {
                            Text("KEY RESULTS (Up to 3 targets)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                            
                            TextField("", text: $kr1, prompt: Text("Key Result 1").foregroundColor(.gray))
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                            
                            TextField("", text: $kr2, prompt: Text("Key Result 2 (Optional)").foregroundColor(.gray))
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                            
                            TextField("", text: $kr3, prompt: Text("Key Result 3 (Optional)").foregroundColor(.gray))
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 8)
                        
                        Button(action: { saveGoal() }) {
                            Text("Save Objective")
                                .font(.system(size: 17, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(!goalTitle.isEmpty && !kr1.isEmpty ? Color(hex: "#0A84FF") : Color.gray.opacity(0.2))
                                .foregroundColor(!goalTitle.isEmpty && !kr1.isEmpty ? .black : .gray)
                                .cornerRadius(12)
                        }
                        .disabled(goalTitle.isEmpty || kr1.isEmpty)
                        .padding(.top, 12)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    private func saveGoal() {
        let titles = [kr1, kr2, kr3]
        viewModel.addNewGoal(
            title: goalTitle,
            category: category,
            targetDate: targetDate,
            keyResultTitles: titles,
            forUser: userId
        )
        dismiss()
    }
}
