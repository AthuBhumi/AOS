import Foundation
import SwiftData
import Models
import Storage
import Logging

public final class AOSUserRepository: UserRepositoryProtocol {
    private let storageManager: AOSStorageManager
    
    public init(storageManager: AOSStorageManager = .shared) {
        self.storageManager = storageManager
    }
    
    private var context: ModelContext {
        guard let context = storageManager.context else {
            AOSLogger.shared.error("AOSUserRepository requested uninitialized ModelContext.")
            fatalError("SwiftData ModelContext is uninitialized.")
        }
        return context
    }
    
    public func fetchUser(byId id: UUID) throws -> User? {
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.id == id })
        do {
            let results = try context.fetch(descriptor)
            return results.first
        } catch {
            AOSLogger.shared.error("Failed to fetch User from database: \(error.localizedDescription)")
            throw StorageError.fetchFailed(error)
        }
    }
    
    public func saveUser(_ user: User) throws {
        context.insert(user)
        user.incrementClock()
        user.syncState = 2 // Pending Update
        try storageManager.save()
    }
    
    public func deleteUser(_ user: User) throws {
        // Soft delete implementation as required by blueprints
        user.isDeleted = true
        user.syncState = 3 // Pending Delete
        user.incrementClock()
        try storageManager.save()
    }
    
    public func incrementUserXP(amount: Int, attribute: String, onUser id: UUID) throws -> User? {
        guard let user = try fetchUser(byId: id) else { return nil }
        
        user.totalXP += amount
        switch attribute.uppercased() {
        case "STR":
            user.strengthStat += 1
        case "INT":
            user.intelligenceStat += 1
        case "CHA":
            user.charismaStat += 1
        case "FOR":
            user.fortuneStat += 1
        default:
            break
        }
        
        user.incrementClock()
        user.syncState = 2 // Pending Update
        try storageManager.save()
        return user
    }
}
