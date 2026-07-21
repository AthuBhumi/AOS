import Foundation
import Models

public enum TypingState: Equatable {
    case idle
    case active
    case complete(TypingSession)
    case failure(String)
}
