import SwiftUI

public struct AddHabitView: View {
    @Bindable private var viewModel: HabitViewModel
    private let userId: UUID
    @Environment(\.dismiss) private var dismiss
    
    @State private var habitTitle = ""
    @State private var cueInput = ""
    @State private var responseInput = ""
    @State private var rewardInput = ""
    
    public init(viewModel: HabitViewModel, userId: UUID) {
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
                    
                    Text("Add Habit Stack")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 16) {
                        // Title
                        TextField("", text: $habitTitle, prompt: Text("Habit Title").foregroundColor(.gray))
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                        
                        // Cue
                        VStack(alignment: .leading, spacing: 6) {
                            Text("1. THE CUE (Trigger)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                            TextField("", text: $cueInput, prompt: Text("After I... (e.g. open laptop)").foregroundColor(.gray))
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                        }
                        
                        // Response
                        VStack(alignment: .leading, spacing: 6) {
                            Text("2. THE RESPONSE (Routine)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                            TextField("", text: $responseInput, prompt: Text("I will... (e.g. write 1 Java method)").foregroundColor(.gray))
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                        }
                        
                        // Reward
                        VStack(alignment: .leading, spacing: 6) {
                            Text("3. THE REWARD (Satisfaction)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                            TextField("", text: $rewardInput, prompt: Text("To receive... (e.g. level up stats)").foregroundColor(.gray))
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                        }
                        
                        Button(action: { saveHabit() }) {
                            Text("Create Stack")
                                .font(.system(size: 17, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(validate() ? Color(hex: "#0A84FF") : Color.gray.opacity(0.2))
                                .foregroundColor(validate() ? .black : .gray)
                                .cornerRadius(12)
                        }
                        .disabled(!validate())
                        .padding(.top, 12)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    private func validate() -> Bool {
        return !habitTitle.isEmpty && !cueInput.isEmpty && !responseInput.isEmpty && !rewardInput.isEmpty
    }
    
    private func saveHabit() {
        viewModel.addNewHabit(
            title: habitTitle,
            cue: cueInput,
            response: responseInput,
            reward: rewardInput,
            forUser: userId
        )
        dismiss()
    }
}
