import Foundation
import os.Logger

public final class AOSLogger {
    public static let shared = AOSLogger()
    
    private let logger = Logger(subsystem: "com.atharva.os", category: "AppCore")
    private var correlationID: String?
    
    private init() {}
    
    public func setCorrelationID(_ id: String) {
        self.correlationID = id
    }
    
    private func logMessage(_ message: String) -> String {
        if let id = correlationID {
            return "[\(id)] \(message)"
        }
        return message
    }
    
    public func debug(_ message: String) {
        logger.debug("\(self.logMessage(message))")
    }
    
    public func info(_ message: String) {
        logger.info("\(self.logMessage(message))")
    }
    
    public func warning(_ message: String) {
        logger.warning("\(self.logMessage(message))")
    }
    
    public func error(_ message: String) {
        logger.error("\(self.logMessage(message))")
    }
}
