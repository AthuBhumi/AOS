import Foundation
import Models

public protocol CompanyBuilderRepositoryProtocol {
    func fetchCompanies(forUser userId: UUID) throws -> [Company]
    func saveCompany(_ company: Company) throws
}
