import Foundation
import Models

public enum ReadingState: Equatable {
    case idle
    case loading
    case loadedBooks([Book])
    case loadedReviewQueue([Flashcard])
    case failure(String)
}
