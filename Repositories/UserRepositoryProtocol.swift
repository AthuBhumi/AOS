import Foundation
import Models

public protocol UserRepositoryProtocol {
    func fetchUser(byId id: UUID) throws -> User?
    func saveUser(_ user: User) throws
    func deleteUser(_ user: User) throws
    func incrementUserXP(amount: Int, attribute: String, onUser id: UUID) throws -> User?
}
