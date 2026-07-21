import Foundation

/// Defines the dynamic stages of user career transformation.
public enum CareerStage: Int, Codable, CaseIterable {
    case employee = 1
    case developer = 2
    case entrepreneur = 3
    case ceo = 4
}

/// Represents the attributes mapped inside the RPG stats leveling engine.
public enum XPAttribute: String, Codable, CaseIterable {
    case strength = "STR"
    case intelligence = "INT"
    case charisma = "CHA"
    case fortune = "FOR"
}

/// System-level synchronization state indicators.
public enum SyncState: Int, Codable {
    case synced = 0
    case pendingCreate = 1
    case pendingUpdate = 2
    case pendingDelete = 3
}

/// Mapped configuration profiles for environments.
public enum EnvironmentProfile: String {
    case development
    case testing
    case staging
    case production
}
