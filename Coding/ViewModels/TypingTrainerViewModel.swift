import Foundation
import Observation
import Models
import Repositories

@Observable
public final class TypingTrainerViewModel {
    public var state: TypingState = .idle
    public var targetPhrase = "public static void main(String[] args) {"
    public var typedPhrase = ""
    public var startTime: Date?
    public var timeSpentSeconds: Double = 0
    
    private let typingRepository: TypingRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    public init(typingRepository: TypingRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.typingRepository = typingRepository
        self.userRepository = userRepository
    }
    
    public func startSession() {
        typedPhrase = ""
        startTime = Date()
        timeSpentSeconds = 0
        state = .active
    }
    
    public func updateTypedText(_ newText: String, userId: UUID) {
        guard case .active = state else { return }
        
        typedPhrase = newText
        
        // If user matched phrase length, finalize session
        if typedPhrase.count >= targetPhrase.count {
            finalizeSession(userId: userId)
        }
    }
    
    public func resetSession() {
        typedPhrase = ""
        startTime = nil
        timeSpentSeconds = 0
        state = .idle
    }
    
    // MARK: - Typing Calculations
    public var currentWPM: Double {
        guard let start = startTime else { return 0.0 }
        let durationMin = Date().timeIntervalSince(start) / 60.0
        if durationMin <= 0 { return 0.0 }
        // WPM = (Characters typed / 5) / time in minutes
        return (Double(typedPhrase.count) / 5.0) / durationMin
    }
    
    public var currentAccuracy: Double {
        if typedPhrase.isEmpty { return 100.0 }
        
        var correctCount = 0
        let targetChars = Array(targetPhrase)
        let typedChars = Array(typedPhrase)
        
        for i in 0..<min(targetChars.count, typedChars.count) {
            if targetChars[i] == typedChars[i] {
                correctCount += 1
            }
        }
        
        return (Double(correctCount) / Double(typedPhrase.count)) * 100.0
    }
    
    private func finalizeSession(userId: UUID) {
        guard let start = startTime else { return }
        let duration = Date().timeIntervalSince(start)
        
        let finalWPM = currentWPM
        let finalAccuracy = currentAccuracy
        
        let session = TypingSession(
            userId: userId,
            targetPhrase: targetPhrase,
            typedPhrase: typedPhrase,
            wpm: finalWPM,
            accuracy: finalAccuracy,
            timeSpentSeconds: duration
        )
        
        do {
            try typingRepository.saveSession(session)
            state = .complete(session)
            
            // If accuracy > 85% and WPM > 40, award +50 XP and INT stat
            if finalAccuracy >= 85.0 && finalWPM >= 40.0 {
                _ = try userRepository.incrementUserXP(amount: 50, attribute: "INT", onUser: userId)
            }
        } catch {
            state = .failure("Failed to save session metrics: \(error.localizedDescription)")
        }
    }
    
    public func loadPhrase(forStage stage: Int) {
        switch stage {
        case 1:
            targetPhrase = "System.out.println(\"Hello World\");"
        case 2:
            targetPhrase = "public static void main(String[] args) {"
        case 3:
            targetPhrase = "ExecutorService executor = Executors.newFixedThreadPool(4);"
        default:
            targetPhrase = "class CEODashboardController implements AutoCloseable {"
        }
    }
}
