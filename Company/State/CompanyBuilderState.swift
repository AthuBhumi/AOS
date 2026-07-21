import Foundation

public enum CompanyBuilderState: Equatable {
    case idle
    case loading
    case loaded
    case failure(String)
}
