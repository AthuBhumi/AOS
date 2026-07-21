import Foundation
import Observation
import Models
import Repositories

@Observable
public final class RoadmapViewModel {
    public var state: CodingState = .idle
    public var selectedNodeForQuiz: RoadmapNode?
    
    private let roadmapRepository: RoadmapRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    public init(roadmapRepository: RoadmapRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.roadmapRepository = roadmapRepository
        self.userRepository = userRepository
    }
    
    public func loadRoadmap() {
        state = .loading
        do {
            var nodes = try roadmapRepository.fetchNodes()
            if nodes.isEmpty {
                let initialNodes = generateDefaultRoadmap()
                try roadmapRepository.bulkCreateNodes(initialNodes)
                nodes = initialNodes
            }
            state = .loaded(nodes)
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
    
    public func submitQuizAnswer(nodeId: UUID, selectedIndex: Int, forUser userId: UUID, completion: @escaping (Result<Bool, CodingError>) -> Void) {
        guard case .loaded(var nodes) = state else {
            completion(.failure(.nodeNotFound))
            return
        }
        
        guard let index = nodes.firstIndex(where: { $0.id == nodeId }) else {
            completion(.failure(.nodeNotFound))
            return
        }
        
        let targetNode = nodes[index]
        
        if selectedIndex == targetNode.correctOptionIndex {
            targetNode.isCompleted = true
            
            do {
                // Save updated node
                try roadmapRepository.saveNode(targetNode)
                
                // Unlock children
                try roadmapRepository.unlockChildNodes(forParentId: nodeId)
                
                // Increment User XP and INT Stat
                _ = try userRepository.incrementUserXP(amount: targetNode.xpReward, attribute: "INT", onUser: userId)
                
                // Reload roadmap items to refresh locked flags
                let updatedNodes = try roadmapRepository.fetchNodes()
                self.state = .loaded(updatedNodes)
                
                completion(.success(true))
            } catch {
                state = .failure("Unable to complete node transaction: \(error.localizedDescription)")
                completion(.success(false))
            }
        } else {
            completion(.failure(.incorrectAnswer))
        }
    }
    
    public var completionPercentage: Double {
        guard case .loaded(let nodes) = state, !nodes.isEmpty else { return 0.0 }
        let completed = nodes.filter { $0.isCompleted }.count
        return (Double(completed) / Double(nodes.count)) * 100.0
    }
    
    private func generateDefaultRoadmap() -> [RoadmapNode] {
        let node1Id = UUID()
        let node2Id = UUID()
        
        let node1 = RoadmapNode(
            id: node1Id,
            title: "1. Java Syntax & Types",
            topicDescription: "Understand primitive data types, basic syntax rules, compiler executions, and memory stacks.",
            studyNotes: "Java is statically typed. It has 8 primitives: byte, short, int, long, float, double, boolean, char. Memory is allocated on Stack (local primitives and references) vs Heap (dynamically allocated objects). Objects are collected via GC.",
            parentId: nil,
            isLocked: false,
            quizQuestion: "Which memory region holds object instances in Java?",
            quizOptions: ["A. Stack Memory", "B. Registers", "C. Heap Memory", "D. Local Context Tables"],
            correctOptionIndex: 2,
            xpReward: 100
        )
        
        let node2 = RoadmapNode(
            id: node2Id,
            title: "2. OOP Paradigms",
            topicDescription: "Master Inheritance, Polymorphism, Abstraction, and Encapsulation principles.",
            studyNotes: "Object-Oriented Programming (OOP) forms the architecture of Java software structures. Polymorphism lets you treat subclasses as parents. Abstraction delegates implementations using Interfaces.",
            parentId: node1Id,
            isLocked: true,
            quizQuestion: "Which OOP concept hides data parameters behind public accessor get/set interfaces?",
            quizOptions: ["A. Inheritance", "B. Encapsulation", "C. Polymorphism", "D. Class Hierarchies"],
            correctOptionIndex: 1,
            xpReward: 120
        )
        
        let node3 = RoadmapNode(
            title: "3. Threading Concurrency",
            topicDescription: "Learn multi-threaded execution pools, synchronization thread safety, and ReentrantLock usage.",
            studyNotes: "Concurrency relies on ExecutorServices or manual Thread definitions. Race conditions occur when multiple threads write shared state. Avoid using synchronized scopes if thread locking requires timeouts.",
            parentId: node2Id,
            isLocked: true,
            quizQuestion: "What concurrency issue occurs when two threads indefinitely block each other?",
            quizOptions: ["A. Race Conditions", "B. Starvation", "C. Deadlocks", "D. Thread Drifts"],
            correctOptionIndex: 2,
            xpReward: 150
        )
        
        return [node1, node2, node3]
    }
}
