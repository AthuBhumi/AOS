import Foundation
import SwiftData
import Core

@Model
public final class StartupIdea: SyncableEntity {
    @Attribute(.unique) public var id: UUID
    public var userId: UUID
    public var title: String
    public var targetMarket: String
    
    // 9 Lean Canvas Boxes
    public var problem: String
    public var solution: String
    public var uniqueValueProp: String
    public var unfairAdvantage: String
    public var customerSegments: String
    public var channels: String
    public var keyMetrics: String
    public var costStructure: String
    public var revenueStreams: String
    
    // SWOT
    public var swotStrengths: String
    public var swotWeaknesses: String
    public var swotOpportunities: String
    public var swotThreats: String
    
    // Competitors & Pricing
    public var competitorsList: String
    public var pricingStrategy: String
    
    @Relationship(deleteRule: .cascade) public var milestones: [StartupMilestone]
    @Relationship(deleteRule: .cascade) public var complianceItems: [ComplianceItem]
    @Relationship(deleteRule: .cascade) public var pitchDecks: [PitchDeck]
    @Relationship(deleteRule: .cascade) public var risks: [RiskRegistration]
    
    public var createdAt: Date
    public var updatedAt: Date
    public var syncState: Int
    public var vectorClock: Int
    public var isDeleted: Bool
    
    public init(
        id: UUID = UUID(),
        userId: UUID,
        title: String,
        targetMarket: String = "",
        problem: String = "",
        solution: String = "",
        uniqueValueProp: String = "",
        unfairAdvantage: String = "",
        customerSegments: String = "",
        channels: String = "",
        keyMetrics: String = "",
        costStructure: String = "",
        revenueStreams: String = "",
        swotStrengths: String = "",
        swotWeaknesses: String = "",
        swotOpportunities: String = "",
        swotThreats: String = "",
        competitorsList: String = "",
        pricingStrategy: String = "",
        milestones: [StartupMilestone] = [],
        complianceItems: [ComplianceItem] = [],
        pitchDecks: [PitchDeck] = [],
        risks: [RiskRegistration] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        syncState: Int = 1,
        vectorClock: Int = 1,
        isDeleted: Bool = false
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.targetMarket = targetMarket
        self.problem = problem
        self.solution = solution
        self.uniqueValueProp = uniqueValueProp
        self.unfairAdvantage = unfairAdvantage
        self.customerSegments = customerSegments
        self.channels = channels
        self.keyMetrics = keyMetrics
        self.costStructure = costStructure
        self.revenueStreams = revenueStreams
        self.swotStrengths = swotStrengths
        self.swotWeaknesses = swotWeaknesses
        self.swotOpportunities = swotOpportunities
        self.swotThreats = swotThreats
        self.competitorsList = competitorsList
        self.pricingStrategy = pricingStrategy
        self.milestones = milestones
        self.complianceItems = complianceItems
        self.pitchDecks = pitchDecks
        self.risks = risks
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.vectorClock = vectorClock
        self.isDeleted = isDeleted
    }
}

@Model
public final class StartupMilestone {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var isCompleted: Bool
    public var startupIdea: StartupIdea?
    
    public init(id: UUID = UUID(), title: String, isCompleted: Bool = false, startupIdea: StartupIdea? = nil) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.startupIdea = startupIdea
    }
}

@Model
public final class ComplianceItem {
    @Attribute(.unique) public var id: UUID
    public var itemText: String
    public var category: String // "Registration", "GST", "MSME"
    public var isCompleted: Bool
    public var startupIdea: StartupIdea?
    
    public init(id: UUID = UUID(), itemText: String, category: String, isCompleted: Bool = false, startupIdea: StartupIdea? = nil) {
        self.id = id
        self.itemText = itemText
        self.category = category
        self.isCompleted = isCompleted
        self.startupIdea = startupIdea
    }
}

@Model
public final class PitchDeck {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var deckUrl: String
    public var askAmount: Double
    public var equityPercent: Double
    public var startupIdea: StartupIdea?
    
    public init(id: UUID = UUID(), title: String, deckUrl: String, askAmount: Double, equityPercent: Double, startupIdea: StartupIdea? = nil) {
        self.id = id
        self.title = title
        self.deckUrl = deckUrl
        self.askAmount = askAmount
        self.equityPercent = equityPercent
        self.startupIdea = startupIdea
    }
}

@Model
public final class RiskRegistration {
    @Attribute(.unique) public var id: UUID
    public var descr: String
    public var impact: Int // 1 to 5
    public var probability: Int // 1 to 5
    public var mitigation: String
    public var startupIdea: StartupIdea?
    
    public init(id: UUID = UUID(), descr: String, impact: Int, probability: Int, mitigation: String, startupIdea: StartupIdea? = nil) {
        self.id = id
        self.descr = descr
        self.impact = impact
        self.probability = probability
        self.mitigation = mitigation
        self.startupIdea = startupIdea
    }
}
