import Foundation
import SwiftData
import Models

@MainActor
public final class AOSStorageManager {
    public static let shared = AOSStorageManager()
    
    public var container: ModelContainer?
    public var context: ModelContext?
    
    private init() {}
    
    /// Initializes the SwiftData model container using the provided database schema array.
    public func initializeContainer(with types: [any PersistentModel.Type], isInMemory: Bool = false) throws {
        let schema = Schema(types)
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isInMemory)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.container = container
            self.context = ModelContext(container)
            AOSLogger.shared.info("SwiftData Container successfully initialized. MemoryOnly: \(isInMemory)")
        } catch {
            AOSLogger.shared.error("Failed to initialize SwiftData Container: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Initializes default container with all system schemas.
    public func setupDefaultContainer(isInMemory: Bool = false) throws {
        let types: [any PersistentModel.Type] = [
            User.self,
            DailyMission.self,
            CodingProblem.self,
            TypingSession.self,
            Book.self,
            Flashcard.self,
            JournalEntry.self,
            Habit.self,
            Goal.self,
            KeyResult.self,
            Transaction.self,
            FinancialAccount.self,
            LeanCanvas.self,
            AdvancedTransaction.self,
            SavingsGoal.self,
            FixedDeposit.self,
            AssetInvestment.self,
            DebtLoan.self,
            BudgetLimit.self,
            StartupIdea.self,
            StartupMilestone.self,
            ComplianceItem.self,
            PitchDeck.self,
            RiskRegistration.self,
            Company.self,
            Employee.self,
            CompanyProject.self,
            Invoice.self,
            SOP.self,
            CEODecision.self
        ]
        try initializeContainer(with: types, isInMemory: isInMemory)
    }
    
    /// Commits active transaction context edits to the local database file.
    public func save() throws {
        guard let context = context else {
            throw StorageError.contextNotInitialized
        }
        
        if context.hasChanges {
            do {
                try context.save()
                AOSLogger.shared.debug("Database context committed successfully.")
            } catch {
                AOSLogger.shared.error("SwiftData commit transaction failed: \(error.localizedDescription)")
                throw StorageError.saveFailed(error)
            }
        }
    }
}
