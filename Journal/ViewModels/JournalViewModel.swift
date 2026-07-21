import Foundation
import Observation
import Models
import Repositories

@Observable
public final class JournalViewModel {
    public var state: JournalState = .idle
    public var entries: [JournalEntry] = []
    public var contentBuffer = ""
    public var moodScore: Double = 5.0
    
    private let journalRepository: JournalRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    public init(journalRepository: JournalRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.journalRepository = journalRepository
        self.userRepository = userRepository
    }
    
    public func loadEntries() {
        state = .loading
        do {
            let fetched = try journalRepository.fetchEntries()
            self.entries = fetched
            state = .loaded(fetched)
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
    
    public func commitEntry(title: String, forUser userId: UUID, completion: @escaping (JournalEntry) -> Void) {
        let distortion = detectCognitiveDistortion(contentBuffer)
        
        let entry = JournalEntry(
            userId: userId,
            title: title,
            content: contentBuffer,
            moodScore: moodScore,
            detectedDistortion: distortion
        )
        
        do {
            try journalRepository.saveEntry(entry)
            
            // Unlocks reframing state if a distortion was caught
            if distortion != nil {
                state = .reframing(entry)
            } else {
                // Award +20 XP for standard journaling check-in
                _ = try userRepository.incrementUserXP(amount: 20, attribute: "CHA", onUser: userId)
                loadEntries()
            }
            completion(entry)
        } catch {
            state = .failure("Failed to save entry: \(error.localizedDescription)")
        }
    }
    
    public func submitReframing(entry: JournalEntry, reframeText: String, forUser userId: UUID) {
        entry.reframedRationale = reframeText
        
        do {
            try journalRepository.saveEntry(entry)
            // Award +40 XP for executing CBT cognitive reframing tasks
            _ = try userRepository.incrementUserXP(amount: 40, attribute: "CHA", onUser: userId)
            contentBuffer = ""
            moodScore = 5.0
            loadEntries()
        } catch {
            state = .failure("Reframing save failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Cognitive Distortion Parser
    public func detectCognitiveDistortion(_ text: String) -> String? {
        let lowercase = text.lowercased()
        
        let catastrophizing = ["worst", "catastrophe", "fail", "ruined", "never succeed"]
        let allOrNothing = ["always", "never", "nothing", "everything", "perfect"]
        let filtering = ["only", "bad", "useless", "ignored"]
        
        for word in catastrophizing {
            if lowercase.contains(word) { return "Catastrophizing" }
        }
        
        for word in allOrNothing {
            if lowercase.contains(word) { return "All-or-Nothing" }
        }
        
        for word in filtering {
            if lowercase.contains(word) { return "Filtering" }
        }
        
        return nil
    }
}
