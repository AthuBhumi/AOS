import Foundation

public enum CompanyBuilderError: Error, LocalizedError {
    case companyNotFound
    
    public var errorDescription: String? {
        switch self {
        case .companyNotFound:
            return "The requested company profile could not be located in local databases."
        }
    }
}
