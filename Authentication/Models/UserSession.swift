import Foundation

/// Represents the active user context in the running application session.
public struct UserSession: Codable, Equatable {
    public let userId: UUID
    public let email: String
    public var displayName: String?
    public var activeStage: Int
    public let accessToken: String
    public let refreshToken: String
    public let tokenExpiryDate: Date
    
    public init(userId: UUID, email: String, displayName: String? = nil, activeStage: Int = 1, accessToken: String, refreshToken: String, tokenExpiryDate: Date) {
        self.userId = userId
        self.email = email
        self.displayName = displayName
        self.activeStage = activeStage
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenExpiryDate = tokenExpiryDate
    }
}
