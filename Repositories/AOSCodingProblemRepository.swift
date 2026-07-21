import Foundation
import SwiftData
import Models
import Storage
import Logging

public final class AOSCodingProblemRepository: CodingProblemRepositoryProtocol {
    private let storageManager: AOSStorageManager
    
    public init(storageManager: AOSStorageManager = .shared) {
        self.storageManager = storageManager
    }
    
    private var context: ModelContext {
        guard let context = storageManager.context else {
            AOSLogger.shared.error("AOSCodingProblemRepository requested uninitialized ModelContext.")
            fatalError("SwiftData ModelContext is uninitialized.")
        }
        return context
    }
    
    public func fetchProblems() throws -> [CodingProblem] {
        let descriptor = FetchDescriptor<CodingProblem>(
            predicate: #Predicate { !$0.isDeleted }
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            AOSLogger.shared.error("Failed to fetch CodingProblems: \(error.localizedDescription)")
            throw StorageError.fetchFailed(error)
        }
    }
    
    public func saveProblem(_ problem: CodingProblem) throws {
        context.insert(problem)
        problem.incrementClock()
        problem.syncState = 2 // Pending Update
        try storageManager.save()
    }
    
    public func bulkCreateProblems(_ problems: [CodingProblem]) throws {
        for problem in problems {
            context.insert(problem)
            problem.syncState = 1 // Pending Create
        }
        try storageManager.save()
    }
}
