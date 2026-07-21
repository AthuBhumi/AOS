import Foundation
import SwiftData
import Core

@Model
public final class Company: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var userId: UUID
    public var name: String
    
    // Financial summaries
    public var revenue: Double
    public var expenses: Double
    
    @Relationship(deleteRule: .cascade) public var employees: [Employee]
    @Relationship(deleteRule: .cascade) public var projects: [CompanyProject]
    @Relationship(deleteRule: .cascade) public var invoices: [Invoice]
    @Relationship(deleteRule: .cascade) public var sops: [SOP]
    
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(
        id: UUID = UUID(),
        userId: UUID,
        name: String,
        revenue: Double = 0.0,
        expenses: Double = 0.0,
        employees: [Employee] = [],
        projects: [CompanyProject] = [],
        invoices: [Invoice] = [],
        sops: [SOP] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        syncState: Int = 1,
        vectorClock: Int = 1,
        isDeleted: Bool = false
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.revenue = revenue
        self.expenses = expenses
        self.employees = employees
        self.projects = projects
        self.invoices = invoices
        self.sops = sops
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}

@Model
public final class Employee {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var role: String
    public var department: String // "Engineering", "Marketing", "Sales"
    public var salary: Double
    public var attendanceDays: Int
    public var totalLeaves: Int
    public var company: Company?
    
    public init(id: UUID = UUID(), name: String, role: String, department: String, salary: Double, attendanceDays: Int = 0, totalLeaves: Int = 0, company: Company? = nil) {
        self.id = id
        self.name = name
        self.role = role
        self.department = department
        self.salary = salary
        self.attendanceDays = attendanceDays
        self.totalLeaves = totalLeaves
        self.company = company
    }
}

@Model
public final class CompanyProject {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var status: String // "To Do", "In Progress", "Done"
    public var dueDate: Date
    public var company: Company?
    
    public init(id: UUID = UUID(), title: String, status: String = "To Do", dueDate: Date = Date().addingTimeInterval(86400 * 14), company: Company? = nil) {
        self.id = id
        self.title = title
        self.status = status
        self.dueDate = dueDate
        self.company = company
    }
}

@Model
public final class Invoice {
    @Attribute(.unique) public var id: UUID
    public var clientName: String
    public var amount: Double
    public var isPaid: Bool
    public var company: Company?
    
    public init(id: UUID = UUID(), clientName: String, amount: Double, isPaid: Bool = false, company: Company? = nil) {
        self.id = id
        self.clientName = clientName
        self.amount = amount
        self.isPaid = isPaid
        self.company = company
    }
}

@Model
public final class SOP {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var policyText: String
    public var company: Company?
    
    public init(id: UUID = UUID(), title: String, policyText: String, company: Company? = nil) {
        self.id = id
        self.title = title
        self.policyText = policyText
        self.company = company
    }
}
