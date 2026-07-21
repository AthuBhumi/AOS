import Foundation
import Models

public enum ProfileState: Equatable {
    case idle
    case loading
    case loaded(User)
    case failure(String)
}
