import Foundation

public struct LoginResponseDTO: Codable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresIn: Int
    public let userId: UUID
    public let email: String
    public let displayName: String?
    public let activeStage: Int
}

public struct SignupResponseDTO: Codable {
    public let message: String
    public let userId: UUID
}

public struct TokenRefreshResponseDTO: Codable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresIn: Int
}
