import SwiftUI
import Models

public struct AIMentorView: View {
    @State private var viewModel: AIMentorViewModel
    private let userId: UUID
    @State private var inputPrompt = ""
    
    public init(viewModel: AIMentorViewModel, userId: UUID) {
        _viewModel = State(initialValue: viewModel)
        self.userId = userId
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Advisor Selector Header Bar
                advisorSelectorHeader()
                    .padding(.vertical, 12)
                    .background(Color(hex: "#1C1C1E").opacity(0.8))
                
                // Chat Log Scroll
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(viewModel.messages) { message in
                                ChatBubbleView(message: message)
                                    .id(message.id)
                            }
                            
                            // Streaming indicator bubble
                            if case .streaming(let content) = viewModel.state {
                                let streamMessage = ChatMessage(userId: userId, advisor: viewModel.activeAdvisor, role: "assistant", content: content)
                                ChatBubbleView(message: streamMessage)
                                    .id("streaming_id")
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    .onChange(of: viewModel.messages.count) {
                        if let last = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: viewModel.state) {
                        if case .streaming = viewModel.state {
                            proxy.scrollTo("streaming_id", anchor: .bottom)
                        }
                    }
                }
                
                // Bottom Input compose bar
                inputComposeSection()
                    .padding(12)
                    .background(Color(hex: "#1C1C1E").opacity(0.8))
            }
        }
        .onAppear {
            viewModel.loadMessages(forUser: userId)
        }
        .navigationTitle("AI Consultation")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func advisorSelectorHeader() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(["COACH", "CTO", "CFO", "CMO"], id: \.self) { role in
                    let isSelected = viewModel.activeAdvisor == role
                    Button(action: {
                        viewModel.selectAdvisor(role, userId: userId)
                    }) {
                        Text(role)
                            .font(.system(size: 13, weight: .bold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(isSelected ? Color(hex: "#0A84FF") : Color.white.opacity(0.1))
                            .foregroundColor(isSelected ? .black : .white)
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func inputComposeSection() -> some View {
        HStack(spacing: 12) {
            TextField("", text: $inputPrompt, prompt: Text("Consult your advisor...").foregroundColor(.gray))
                .padding(12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
                .foregroundColor(.white)
                .autocorrectionDisabled()
            
            Button(action: {
                let prompt = inputPrompt
                inputPrompt = ""
                viewModel.sendPrompt(prompt, userId: userId)
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(inputPrompt.isEmpty ? .gray : Color(hex: "#0A84FF"))
            }
            .disabled(inputPrompt.isEmpty)
        }
    }
}
