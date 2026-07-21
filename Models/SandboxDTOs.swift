import Foundation

public struct CompileRequestDTO: Codable {
    public let code: String
    public let language: String // e.g. "java"
    public let problemId: UUID
}

public struct CompileResponseDTO: Codable {
    public let status: String // "SUCCESS", "COMPILE_ERROR", "RUNTIME_ERROR"
    public let stdout: String
    public let stderr: String
    public let executionTimeMs: Int
}
