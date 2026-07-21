import Foundation
import Observation
import Models
import Repositories

@Observable
public final class ProfileViewModel {
    public var state: ProfileState = .idle
    public var updatedDisplayName = ""
    public var isSaving = false
    
    private let userRepository: UserRepositoryProtocol
    
    public init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    public func loadProfile(userId: UUID) {
        state = .loading
        do {
            if let user = try userRepository.fetchUser(byId: userId) {
                state = .loaded(user)
                updatedDisplayName = user.displayName ?? ""
            } else {
                state = .failure(ProfileError.userNotFound.localizedDescription)
            }
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
    
    public func updateProfileName(for userId: UUID, completion: @escaping (Bool) -> Void) {
        guard !updatedDisplayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            state = .failure("Profile display name cannot be blank.")
            completion(false)
            return
        }
        
        isSaving = true
        do {
            if let user = try userRepository.fetchUser(byId: userId) {
                user.displayName = updatedDisplayName
                try userRepository.saveUser(user)
                state = .loaded(user)
                isSaving = false
                completion(true)
            } else {
                state = .failure(ProfileError.userNotFound.localizedDescription)
                completion(false)
            }
        } catch {
            state = .failure(error.localizedDescription)
            isSaving = false
            completion(false)
        }
    }
    
    public func grantXP(amount: Int, attribute: String, for userId: UUID) {
        do {
            if let updatedUser = try userRepository.incrementUserXP(amount: amount, attribute: attribute, onUser: userId) {
                state = .loaded(updatedUser)
            }
        } catch {
            state = .failure("XP update failed: \(error.localizedDescription)")
        }
    }
    
    /// Helper detailing stage strings
    public func getStageName(for stage: Int) -> String {
        switch stage {
        case 1: return "Employee"
        case 2: return "Skilled Developer"
        case 3: return "Entrepreneur"
        case 4: return "CEO"
        default: return "Beginner"
        }
    }
}
