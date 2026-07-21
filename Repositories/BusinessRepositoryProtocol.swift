import Foundation
import Models

public protocol BusinessRepositoryProtocol {
    func fetchCanvas(forUser userId: UUID) throws -> LeanCanvas?
    func saveCanvas(_ canvas: LeanCanvas) throws
}
