import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public enum APIEndpoint {
    case signup(body: Data)
    case login(body: Data)
    case logout(refreshToken: String)
    case tokenRefresh(refreshToken: String)
    case sync(payload: Data)
    case sandboxCompile(codePayload: Data)
    case aiConsult(promptPayload: Data)
    case speechAnalyze(audioData: Data)
    
    public var path: String {
        switch self {
        case .signup:
            return "/v1/auth/signup"
        case .login:
            return "/v1/auth/login"
        case .logout:
            return "/v1/auth/logout"
        case .tokenRefresh:
            return "/v1/auth/refresh"
        case .sync:
            return "/v1/sync"
        case .sandboxCompile:
            return "/v1/academy/sandbox/compile"
        case .aiConsult:
            return "/v1/ai/mentor/consult"
        case .speechAnalyze:
            return "/v1/speech/analyze"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .signup, .login, .logout, .tokenRefresh, .sync, .sandboxCompile, .aiConsult, .speechAnalyze:
            return .post
        }
    }
    
    public var headers: [String: String] {
        var baseHeaders = [
            "Accept": "application/json",
            "X-Client-Platform": "iOS"
        ]
        
        switch self {
        case .speechAnalyze:
            baseHeaders["Content-Type"] = "multipart/form-data; boundary=AOSBoundary"
        default:
            baseHeaders["Content-Type"] = "application/json"
        }
        
        return baseHeaders
    }
}
