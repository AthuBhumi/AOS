import Foundation

public struct APIErrorPayload: Decodable, Error {
    public let errorCode: String
    public let message: String
    public let timestamp: String
    public let details: [ValidationErrorDetail]?
}

public struct ValidationErrorDetail: Decodable {
    public let field: String
    public let issue: String
}

public enum NetworkError: Error, LocalizedError {
    case invalidURL
    case badRequest(payload: APIErrorPayload?)
    case unauthorized
    case forbidden
    case rateLimited
    case serverError(statusCode: Int)
    case connectionFailure(Error)
    case parsingFailure(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The requested URL configuration is invalid."
        case .badRequest(let payload):
            return payload?.message ?? "Bad request arguments."
        case .unauthorized:
            return "Session expired or authentication failed."
        case .forbidden:
            return "Access scopes do not permit this operation."
        case .rateLimited:
            return "Request quota exceeded. Please try again later."
        case .serverError(let code):
            return "Remote server encountered an error (HTTP \(code))."
        case .connectionFailure(let err):
            return "Network connection failure: \(err.localizedDescription)"
        case .parsingFailure(let err):
            return "Failed to parse API response payload: \(err.localizedDescription)"
        }
    }
}
