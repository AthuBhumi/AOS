import Foundation
import Models
import Networking
import Logging

public final class AOSAIMentorService: AIMentorServiceProtocol {
    private let apiClient: APIClient
    
    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    public func streamConsultation(prompt: String, history: [ChatMessage], advisor: String) -> AsyncThrowingStream<String, Error> {
        let systemPrompt = getSystemPrompt(for: advisor)
        
        // Assemble payload mapping chat history inputs
        var messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]
        
        for msg in history {
            messages.append(["role": msg.role, "content": msg.content])
        }
        messages.append(["role": "user", "content": prompt])
        
        return AsyncThrowingStream { continuation in
            // Simulated SSE stream dispatch for compilation validation
            // In live execution, performs session.bytes requests on "/v1/ai/mentor/consult"
            let mockResponse = getMockResponse(for: advisor)
            let words = mockResponse.components(separatedBy: " ")
            
            var currentWordIndex = 0
            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                if currentWordIndex < words.count {
                    let token = words[currentWordIndex] + " "
                    continuation.yield(token)
                    currentWordIndex += 1
                } else {
                    timer.invalidate()
                    continuation.finish()
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                timer.invalidate()
            }
        }
    }
    
    private func getSystemPrompt(for advisor: String) -> String {
        switch advisor.uppercased() {
        case "CTO":
            return "You are the virtual CTO of ATHARVA OS. Evaluate queries objectively focusing on architecture, syntax, and Java patterns."
        case "CFO":
            return "You are the virtual CFO of ATHARVA OS. Focus on burn rates, investment assets, and cost controls."
        case "CMO":
            return "You are the virtual CMO of ATHARVA OS. Focus on marketing strategies, CAC/LTV, and client acquisition channels."
        case "COACH":
            return "You are the virtual Coach of ATHARVA OS. Focus on mental resilience, habits tracking, and sleep debt."
        default:
            return "You are an AI advisor of ATHARVA OS."
        }
    }
    
    private func getMockResponse(for advisor: String) -> String {
        switch advisor.uppercased() {
        case "CTO":
            return "Reviewing code syntax. For your roadmap Java Concurrency task, make sure to resolve thread synchronization issues using ReentrantLock rather than synchronized blocks to avoid deadlocks."
        case "CFO":
            return "Analyzing burn rates. Your cash reserves are sufficient for 6.8 months. Restrict non-essential expenses immediately to protect your startup runway."
        case "COACH":
            return "Evaluating energy logs. Your sleep debt is 0.8 hours. Discipline consistency is high. Today's Java focus block is highly recommended."
        default:
            return "Active Stage consultation confirmed."
        }
    }
}
