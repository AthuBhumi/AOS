import Foundation

public enum BusinessBuilderState: Equatable {
    case idle
    case loading
    case loaded
    case failure(String)
}
