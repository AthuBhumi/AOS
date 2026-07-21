import Foundation
import Models

public enum AIMentorState: Equatable {
    case idle
    case loading
    case streaming(String)
    case failure(String)
}
