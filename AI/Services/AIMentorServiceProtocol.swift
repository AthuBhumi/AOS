import Foundation
import Models

public protocol AIMentorServiceProtocol {
    func streamConsultation(prompt: String, history: [ChatMessage], advisor: String) -> AsyncThrowingStream<String, Error>
}
