import XCTest
import SwiftData
@testable import Common
@testable import Core
@testable import Models
@testable import Storage
@testable import Repositories
@testable import Networking
@testable import Coding

final class AOSCodingPracticeTests: XCTestCase {
    private var container: ModelContainer?
    private var manager: AOSStorageManager = .shared
    
    override func setUpWithError() throws {
        // Initialize storage manager in-memory with User and CodingProblem schemas
        try manager.initializeContainer(with: [User.self, CodingProblem.self], isInMemory: true)
        container = manager.container
    }
    
    override func tearDownWithError() throws {
        container = nil
        manager.context = nil
        manager.container = nil
    }
    
    // MARK: - Core Sandbox Practice Tests
    func testCodingPracticeLifecycleFlow() throws {
        let userRepo = AOSUserRepository(storageManager: manager)
        let problemRepo = AOSCodingProblemRepository(storageManager: manager)
        let mockClient = APIClient(baseURL: URL(string: "https://api.domain.com")!)
        
        let viewModel = CodingPracticeViewModel(problemRepository: problemRepo, userRepository: userRepo, apiClient: mockClient)
        
        let userId = UUID()
        let testUser = User(id: userId, displayName: "Atharva", totalXP: 100)
        try userRepo.saveUser(testUser)
        
        // Load coding challenges
        viewModel.loadProblems()
        
        guard case .loaded(let problems) = viewModel.state else {
            XCTFail("State not loaded")
            return
        }
        
        XCTAssertEqual(problems.count, 2)
        XCTAssertEqual(problems[0].title, "Array Reversal")
        
        // Select problem
        viewModel.selectProblem(problems[0])
        XCTAssertEqual(viewModel.codeBuffer, problems[0].codeBoilerplate)
        
        // Submit code compilation: mock endpoint compile triggers success passes, awards +100 XP
        let compileExpectation = self.expectation(description: "Code compiles successfully")
        
        viewModel.compileAndRun(forUser: userId) { result in
            switch result {
            case .failure(let error):
                XCTFail("Should succeed: \(error.localizedDescription)")
            case .success(let response):
                // In APIClient mock, endpoint compile yields success payload returns
                XCTAssertEqual(response.status, "SUCCESS")
            }
            compileExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.5)
        
        // Verify User stats updates: totalXP increases to 200 (100 base + 100 reward)
        let updatedUser = try userRepo.fetchUser(byId: userId)
        XCTAssertEqual(updatedUser?.totalXP, 200)
        XCTAssertEqual(updatedUser?.intelligenceStat, 2)
    }
}
