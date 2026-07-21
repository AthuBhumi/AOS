import SwiftUI

public struct EditCanvasBoxView: View {
    @Bindable private var viewModel: BusinessViewModel
    let boxKey: String
    let boxTitle: String
    @State private var textInput: String
    private let userId: UUID
    let onComplete: () -> Void
    @State private var successAlert = false
    
    public init(viewModel: BusinessViewModel, boxKey: String, boxTitle: String, initialContent: String, userId: UUID, onComplete: @escaping () -> Void) {
        self.viewModel = viewModel
        self.boxKey = boxKey
        self.boxTitle = boxTitle
        _textInput = State(initialValue: initialContent)
        self.userId = userId
        self.onComplete = onComplete
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)
                
                Text(boxTitle)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 12) {
                    TextEditor(text: $textInput)
                        .frame(height: 220)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    if successAlert {
                        Text("Canvas revised successfully! +50 XP awarded.")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#30D158"))
                    }
                    
                    Button("Save Assumptions") {
                        viewModel.updateCanvasBox(boxKey: boxKey, text: textInput, forUser: userId) { success in
                            if success {
                                successAlert = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    onComplete()
                                }
                            }
                        }
                    }
                    .font(.system(size: 17, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(!textInput.isEmpty ? Color(hex: "#0A84FF") : Color.gray.opacity(0.2))
                    .foregroundColor(!textInput.isEmpty ? .black : .gray)
                    .cornerRadius(12)
                    .disabled(textInput.isEmpty || successAlert)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}
