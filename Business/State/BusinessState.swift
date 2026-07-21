import Foundation
import Models

public enum BusinessState: Equatable {
    case idle
    case loading
    case loaded(LeanCanvas)
    case failure(String)
}
