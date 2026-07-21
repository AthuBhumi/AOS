import Foundation
import SwiftData
import Models
import Storage
import Logging

public final class AOSCompanyBuilderRepository: CompanyBuilderRepositoryProtocol {
    private let storageManager: AOSStorageManager
    
    public init(storageManager: AOSStorageManager = .shared) {
        self.storageManager = storageManager
    }
    
    private var context: ModelContext {
        guard let context = storageManager.context else {
            AOSLogger.shared.error("AOSCompanyBuilderRepository requested uninitialized ModelContext.")
            fatalError("SwiftData ModelContext is uninitialized.")
        }
        return context
    }
    
    public func fetchCompanies(forUser userId: UUID) throws -> [Company] {
        let desc = FetchDescriptor<Company>(
            predicate: #Predicate { $0.userId == userId && !$0.isDeleted },
            sortBy: [SortDescriptor(\.createdAt, order: .descending)]
        )
        return try context.fetch(desc)
    }
    
    public func saveCompany(_ company: Company) throws {
        context.insert(company)
        company.incrementClock()
        company.syncState = 2
        try storageManager.save()
    }
}
