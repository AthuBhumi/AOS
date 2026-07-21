import SwiftUI
import Models

public struct ActiveRecallView: View {
    @State private var viewModel: ReadingViewModel
    private let userId: UUID
    @State private var isFlipped = false
    
    public init(viewModel: ReadingViewModel, userId: UUID) {
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
                    Button("Retry") { viewModel.loadReviewQueue() }
                        .foregroundColor(Color(hex: "#0A84FF"))
                }
                
            case .loadedBooks, .loadedReviewQueue:
                let queue = viewModel.reviewQueue
                
                if queue.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 64))
                            .foregroundColor(Color(hex: "#30D158"))
                        
                        Text("Queue Cleared!")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("All active recall cards are scheduled for future intervals.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .padding(.top, 40)
                    Spacer()
                } else {
                    let card = queue.first!
                    
                    VStack(spacing: 24) {
                        // Progress indicators
                        Text("CARD 1 OF \(queue.count)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                            .tracking(1.0)
                            .padding(.top, 24)
                        
                        // Flipping Card Graphic
                        ZStack {
                            if !isFlipped {
                                cardFront(question: card.question)
                            } else {
                                cardBack(answer: card.answer)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 280)
                        .padding(.horizontal, 20)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                isFlipped.toggle()
                            }
                        }
                        
                        // Rating selector buttons
                        if isFlipped {
                            VStack(spacing: 12) {
                                Text("Rate your recall quality:")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 8) {
                                    scoreButton(title: "Forgot", score: 1, cardId: card.id)
                                    scoreButton(title: "Hard", score: 2, cardId: card.id)
                                    scoreButton(title: "Good", score: 3, cardId: card.id)
                                    scoreButton(title: "Perfect", score: 5, cardId: card.id)
                                }
                            }
                            .padding(.horizontal, 20)
                            .transition(.opacity)
                        } else {
                            Text("Tap Card to reveal Answer")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadReviewQueue()
        }
        .navigationTitle("Active Recall")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func cardFront(question: String) -> some View {
        VStack {
            Spacer()
            Text(question)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(24)
            Spacer()
            Text("QUESTION")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(hex: "#0A84FF"))
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, minHeight: 280)
        .background(Color(hex: "#1C1C1E"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func cardBack(answer: String) -> some View {
        VStack {
            Spacer()
            Text(answer)
                .font(.system(size: 17))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(24)
                .lineSpacing(6)
            Spacer()
            Text("ANSWER")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(hex: "#30D158"))
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, minHeight: 280)
        .background(Color(hex: "#1C1C1E"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
    
    private func scoreButton(title: String, score: Int, cardId: UUID) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                isFlipped = false
                viewModel.submitReviewScore(cardId: cardId, score: score, forUser: userId)
            }
        }) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(scoreColor(score))
                .cornerRadius(8)
        }
    }
    
    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 1: return Color(hex: "#FF453A")
        case 2: return Color(hex: "#FFD60A")
        case 3: return Color(hex: "#0A84FF")
        default: return Color(hex: "#30D158")
        }
    }
}
extension Flashcard: Identifiable {}
