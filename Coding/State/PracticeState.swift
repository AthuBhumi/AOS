import Foundation
import Models

public enum PracticeState: Equatable {
    case idle
    case loading
    case loaded([CodingProblem])
    case compiling
    case compiled(CompileResponseDTO)
    case failure(String)
}
extension CompileResponseDTO: Equatable {
    public static func == (lhs: CompileResponseDTO, rhs: CompileResponseDTO) -> Bool {
        return lhs.status == rhs.status && lhs.stdout == rhs.stdout && lhs.stderr == rhs.stderr && lhs.executionTimeMs == rhs.executionTimeMs
    }
}
