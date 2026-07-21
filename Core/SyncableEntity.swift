import Foundation

/// Protocol that database models must conform to for offline-first CloudKit synchronization.
public protocol SyncableEntity: AnyObject {
    var id: UUID { get set }
    var syncState: Int { get set }
    var vectorClock: Int { get set }
    var updatedAt: Date { get set }
    var isDeleted: Bool { get set }
    
    /// Increments the local vector clock when mutations occur.
    func incrementClock()
}

extension SyncableEntity {
    public func incrementClock() {
        self.vectorClock += 1
        self.updatedAt = Date()
    }
}
