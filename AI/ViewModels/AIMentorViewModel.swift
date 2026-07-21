import Foundation
import Observation
import Models
import Repositories
import AI

@Observable
public final class AIMentorViewModel {
    public var messages: [ChatMessage] = []
    public var state: AIMentorState = .idle
    public var activeAdvisor = "COACH" // Default to Coach advisor
    
    private let aiService: AIMentorServiceProtocol
    private let chatRepository: ChatMessageRepositoryProtocol
    
    private let userRepository: UserRepositoryProtocol
    private let typingRepository: TypingRepositoryProtocol
    private let readingRepository: ReadingRepositoryProtocol
    private let financeRepository: FinanceRepositoryProtocol
    private let businessRepository: BusinessBuilderRepositoryProtocol
    
    public init(
        aiService: AIMentorServiceProtocol,
        chatRepository: ChatMessageRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        typingRepository: TypingRepositoryProtocol,
        readingRepository: ReadingRepositoryProtocol,
        financeRepository: FinanceRepositoryProtocol,
        businessRepository: BusinessBuilderRepositoryProtocol
    ) {
        self.aiService = aiService
        self.chatRepository = chatRepository
        self.userRepository = userRepository
        self.typingRepository = typingRepository
        self.readingRepository = readingRepository
        self.financeRepository = financeRepository
        self.businessRepository = businessRepository
    }
    
    public func loadMessages(forUser userId: UUID) {
        do {
            self.messages = try chatRepository.fetchMessages(forUser: userId, advisor: activeAdvisor, limit: 20)
            state = .idle
        } catch {
            state = .failure("Unable to fetch message logs: \(error.localizedDescription)")
        }
    }
    
    public func selectAdvisor(_ advisorName: String, userId: UUID) {
        activeAdvisor = advisorName
        loadMessages(forUser: userId)
    }
    
    public func sendPrompt(_ text: String, userId: UUID) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let userMessage = ChatMessage(userId: userId, advisor: activeAdvisor, role: "user", content: trimmed)
        
        do {
            try chatRepository.saveMessage(userMessage)
            messages.append(userMessage)
            
            // Set state to streaming
            state = .streaming("")
            
            // Generate Context Payload
            let contextualPrompt = buildContextualPrompt(forPrompt: trimmed, userId: userId)
            
            Task {
                do {
                    let tokenStream = aiService.streamConsultation(prompt: contextualPrompt, history: messages, advisor: activeAdvisor)
                    
                    var responseContent = ""
                    for try await token in tokenStream {
                        responseContent += token
                        state = .streaming(responseContent)
                    }
                    
                    // Stream finished: commit to database
                    let assistantMessage = ChatMessage(userId: userId, advisor: activeAdvisor, role: "assistant", content: responseContent)
                    try chatRepository.saveMessage(assistantMessage)
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.messages.append(assistantMessage)
                        self?.state = .idle
                    }
                } catch {
                    DispatchQueue.main.async { [weak self] in
                        self?.state = .failure("AI response failed: \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            state = .failure("Failed to save message: \(error.localizedDescription)")
        }
    }
    
    private func buildContextualPrompt(forPrompt prompt: String, userId: UUID) -> String {
        var context = "[User Progress Context]\n"
        
        if let user = try? userRepository.fetchUser(byId: userId) {
            context += "- Level: \(user.level) (XP: \(user.totalXP))\n"
            context += "- Stats: INT=\(user.intelligenceStat), STR=\(user.strengthStat), CHA=\(user.charismaStat), FOR=\(user.fortuneStat)\n"
        }
        
        if let typingSessions = try? typingRepository.fetchSessions(forUser: userId), !typingSessions.isEmpty {
            let avgWPM = typingSessions.reduce(0.0) { $0 + $1.wpm } / Double(typingSessions.count)
            context += String(format: "- Typing Speed: %.1f WPM\n", avgWPM)
        }
        
        if let books = try? readingRepository.fetchBooks() {
            let total = books.reduce(0) { $0 + $1.totalPages }
            let completed = books.reduce(0) { $0 + $1.completedPages }
            context += "- Reading Progress: \(completed)/\(total) pages completed\n"
        }
        
        if let cash = try? financeRepository.fetchAccounts(forUser: userId).filter({ $0.type == "Cash" }).reduce(0.0, { $0 + $1.balance }),
           let expenses = try? financeRepository.fetchTransactions(forUser: userId).filter({ $0.category.contains("Expense") }).reduce(0.0, { $0 + $1.amount }) {
            let runway = expenses > 0 ? (cash / expenses) : 99.0
            context += String(format: "- Capital Runway: %.1f months (Cash: $%.0f, Burn: $%.0f)\n", runway, cash, expenses)
        }
        
        if let ideas = try? businessRepository.fetchIdeas(forUser: userId), let primary = ideas.first {
            let boxes = [primary.problem, primary.solution, primary.uniqueValueProp, primary.unfairAdvantage, primary.customerSegments, primary.channels, primary.keyMetrics, primary.costStructure, primary.revenueStreams]
            let completedCount = boxes.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
            let percent = (Double(completedCount) / 9.0) * 100.0
            context += String(format: "- Lean Canvas Completeness: %.1f%%\n", percent)
        }
        
        context += "\nPrompt: \(prompt)"
        return context
    }
    
    public func resetChatHistory(userId: UUID) {
        do {
            try chatRepository.clearHistory(forUser: userId, advisor: activeAdvisor)
            messages.removeAll()
            state = .idle
        } catch {
            state = .failure("Failed to clear history: \(error.localizedDescription)")
        }
    }
}
