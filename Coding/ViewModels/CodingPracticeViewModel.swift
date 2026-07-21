import Foundation
import Observation
import Models
import Repositories
import Networking
import Coding

@Observable
public final class CodingPracticeViewModel {
    public var state: PracticeState = .idle
    public var selectedProblem: CodingProblem?
    public var codeBuffer = ""
    
    private let problemRepository: CodingProblemRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let apiClient: APIClient
    
    public init(problemRepository: CodingProblemRepositoryProtocol, userRepository: UserRepositoryProtocol, apiClient: APIClient) {
        self.problemRepository = problemRepository
        self.userRepository = userRepository
        self.apiClient = apiClient
    }
    
    public func loadProblems() {
        state = .loading
        do {
            var problems = try problemRepository.fetchProblems()
            if problems.isEmpty {
                let initial = generateDefaultProblems()
                try problemRepository.bulkCreateProblems(initial)
                problems = initial
            }
            state = .loaded(problems)
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
    
    public func selectProblem(_ problem: CodingProblem) {
        selectedProblem = problem
        codeBuffer = problem.codeBoilerplate
    }
    
    public func compileAndRun(forUser userId: UUID, completion: @escaping (Result<CompileResponseDTO, PracticeError>) -> Void) {
        guard let problem = selectedProblem else {
            completion(.failure(.problemNotFound))
            return
        }
        
        state = .compiling
        
        let requestDTO = CompileRequestDTO(code: codeBuffer, language: "java", problemId: problem.id)
        guard let payload = try? JSONEncoder().encode(requestDTO) else {
            state = .failure("Serialization error.")
            return
        }
        
        let endpoint = APIEndpoint.sandboxCompile(codePayload: payload)
        apiClient.execute(endpoint) { [weak self] (result: Result<CompileResponseDTO, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self?.state = .failure(error.localizedDescription)
                case .success(let dto):
                    self?.state = .compiled(dto)
                    
                    if dto.status == "SUCCESS" {
                        problem.isCompleted = true
                        try? self?.problemRepository.saveProblem(problem)
                        // Award XP
                        _ = try? self?.userRepository.incrementUserXP(amount: problem.xpReward, attribute: "INT", onUser: userId)
                    }
                    completion(.success(dto))
                }
            }
        }
    }
    
    private func generateDefaultProblems() -> [CodingProblem] {
        return [
            CodingProblem(
                title: "Array Reversal",
                difficulty: "Easy",
                problemDescription: "Write a method to reverse an array of integers in-place. Do not allocate extra space.\n\nExample:\nInput: [1, 2, 3]\nOutput: [3, 2, 1]",
                codeBoilerplate: "public class Solution {\n    public void reverse(int[] nums) {\n        // Write your code here\n    }\n}"
            ),
            CodingProblem(
                title: "Binary Search",
                difficulty: "Medium",
                problemDescription: "Implement binary search on a sorted array of integers. Return the index of the target, or -1 if not found.",
                codeBoilerplate: "public class Solution {\n    public int search(int[] nums, int target) {\n        // Write your code here\n        return -1;\n    }\n}"
            )
        ]
    }
}
