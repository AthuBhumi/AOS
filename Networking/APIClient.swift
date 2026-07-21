import Foundation

public final class APIClient {
    private let session: URLSession
    private let baseURL: URL
    private let lock = NSLock()
    private var isRefreshing = false
    private var refreshQueue: [(String?) -> Void] = []
    
    public init(baseURL: URL, configuration: URLSessionConfiguration = .default) {
        self.baseURL = baseURL
        self.session = URLSession(configuration: configuration)
    }
    
    /// Executes a request and returns the decoded model.
    public func execute<T: Decodable>(_ endpoint: APIEndpoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        buildRequest(for: endpoint) { [weak self] result in
            switch result {
            case .failure(let err):
                completion(.failure(err))
            case .success(let request):
                self?.performRequest(request, attempt: 0, endpoint: endpoint, completion: completion)
            }
        }
    }
    
    private func performRequest<T: Decodable>(_ request: URLRequest, attempt: Int, endpoint: APIEndpoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(.connectionFailure(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.serverError(statusCode: -1)))
                return
            }
            
            // Check status codes
            switch httpResponse.statusCode {
            case 200...299:
                guard let data = data else {
                    completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    completion(.failure(.parsingFailure(error)))
                }
                
            case 401:
                // Trigger Token Refresh Flow
                self?.handleTokenRefresh { newToken in
                    guard let token = newToken else {
                        completion(.failure(.unauthorized))
                        return
                    }
                    var authenticatedRequest = request
                    authenticatedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    self?.performRequest(authenticatedRequest, attempt: attempt, endpoint: endpoint, completion: completion)
                }
                
            case 429:
                // Rate limited, retry with exponential backoff if attempt < 3
                if attempt < 3 {
                    let delay = pow(2.0, Double(attempt))
                    DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                        self?.performRequest(request, attempt: attempt + 1, endpoint: endpoint, completion: completion)
                    }
                } else {
                    completion(.failure(.rateLimited))
                }
                
            case 400:
                let payload = self?.parseError(from: data)
                completion(.failure(.badRequest(payload: payload)))
                
            case 403:
                completion(.failure(.forbidden))
                
            default:
                completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
            }
        }.resume()
    }
    
    private func buildRequest(for endpoint: APIEndpoint, completion: @escaping (Result<URLRequest, NetworkError>) -> Void) {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        switch endpoint {
        case .signup(let body), .login(let body), .sync(let body), .sandboxCompile(let body), .aiConsult(let body):
            request.httpBody = body
        case .speechAnalyze(let audioData):
            request.httpBody = audioData
        default:
            break
        }
        
        // Append active Bearer Token if session exists
        // (Uses dummy token extraction logic; in target it pulls from Keychain)
        let dummyToken = "dummy_access_token"
        request.setValue("Bearer \(dummyToken)", forHTTPHeaderField: "Authorization")
        completion(.success(request))
    }
    
    private func handleTokenRefresh(completion: @escaping (String?) -> Void) {
        lock.lock()
        if isRefreshing {
            refreshQueue.append(completion)
            lock.unlock()
            return
        }
        
        isRefreshing = true
        lock.unlock()
        
        // Simulates refresh endpoint call, rotates refresh token
        // In real client, pulls refresh token from Keychain and executes .tokenRefresh
        let success = true
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.lock.lock()
            self?.isRefreshing = false
            let newToken = success ? "new_rotated_dummy_token" : nil
            let queue = self?.refreshQueue ?? []
            self?.refreshQueue.removeAll()
            self?.lock.unlock()
            
            completion(newToken)
            for cachedCompletion in queue {
                cachedCompletion(newToken)
            }
        }
    }
    
    private func parseError(from data: Data?) -> APIErrorPayload? {
        guard let data = data else { return nil }
        return try? JSONDecoder().decode(APIErrorPayload.self, from: data)
    }
}
