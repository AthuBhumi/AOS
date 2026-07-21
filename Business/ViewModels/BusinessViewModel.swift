import Foundation
import Observation
import Models
import Repositories

@Observable
public final class BusinessViewModel {
    public var state: BusinessState = .idle
    public var activeCanvas: LeanCanvas?
    
    private let businessRepository: BusinessRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    public init(businessRepository: BusinessRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.businessRepository = businessRepository
        self.userRepository = userRepository
    }
    
    public func loadCanvas(forUser userId: UUID) {
        state = .loading
        do {
            if let canvas = try businessRepository.fetchCanvas(forUser: userId) {
                self.activeCanvas = canvas
                state = .loaded(canvas)
            } else {
                // Initialize default empty Lean Canvas
                let emptyCanvas = LeanCanvas(userId: userId, startupName: "AOS Startup MVP")
                try businessRepository.saveCanvas(emptyCanvas)
                self.activeCanvas = emptyCanvas
                state = .loaded(emptyCanvas)
            }
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
    
    public func updateCanvasBox(boxKey: String, text: String, forUser userId: UUID, completion: @escaping (Bool) -> Void) {
        guard let canvas = activeCanvas else {
            completion(false)
            return
        }
        
        switch boxKey {
        case "problem": canvas.problem = text
        case "solution": canvas.solution = text
        case "uvp": canvas.uniqueValueProp = text
        case "advantage": canvas.unfairAdvantage = text
        case "segments": canvas.customerSegments = text
        case "channels": canvas.channels = text
        case "metrics": canvas.keyMetrics = text
        case "cost": canvas.costStructure = text
        case "revenue": canvas.revenueStreams = text
        default: break
        }
        
        canvas.updatedAt = Date()
        
        do {
            try businessRepository.saveCanvas(canvas)
            
            // Award +50 XP and CHA on canvas box completion / revisions
            _ = try userRepository.incrementUserXP(amount: 50, attribute: "CHA", onUser: userId)
            
            loadCanvas(forUser: userId)
            completion(true)
        } catch {
            state = .failure("Failed to write canvas box: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // MARK: - Completeness Calculations
    public var completenessScore: Double {
        guard let canvas = activeCanvas else { return 0.0 }
        
        let boxes = [
            canvas.problem, canvas.solution, canvas.uniqueValueProp,
            canvas.unfairAdvantage, canvas.customerSegments, canvas.channels,
            canvas.keyMetrics, canvas.costStructure, canvas.revenueStreams
        ]
        
        let completedCount = boxes.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
        return (Double(completedCount) / 9.0) * 100.0
    }
    
    public var isRevisionOverdue: Bool {
        guard let canvas = activeCanvas else { return false }
        let days = Calendar.current.dateComponents([.day], from: canvas.updatedAt, to: Date()).day ?? 0
        return days >= 14
    }
}
