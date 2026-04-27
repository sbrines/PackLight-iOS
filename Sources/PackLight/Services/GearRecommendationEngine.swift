import Foundation

// Recommendation based on trip conditions: location, elevation, season, duration
struct GearRecommendation {
    let categoryName: String
    let categoryIcon: String
    let reason: String
    let priority: RecommendationPriority
}

enum RecommendationPriority: Int, Comparable {
    case required = 0
    case strongly = 1
    case suggested = 2
    case optional = 3

    static func < (lhs: RecommendationPriority, rhs: RecommendationPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var label: String {
        switch self {
        case .required: return "Required"
        case .strongly: return "Strongly Recommended"
        case .suggested: return "Suggested"
        case .optional: return "Optional"
        }
    }
}

struct TripConditions {
    let maxElevationFeet: Int
    let minElevationFeet: Int
    let startDate: Date
    let durationDays: Int
    let terrainType: TerrainType
    let distanceMiles: Double

    var season: Season {
        let month = Calendar.current.component(.month, from: startDate)
        switch month {
        case 12, 1, 2: return .winter
        case 3, 4, 5: return .spring
        case 6, 7, 8: return .summer
        default: return .fall
        }
    }

    var isHighAlpine: Bool { maxElevationFeet > 10000 }
    var isExtendedTrip: Bool { durationDays > 3 }
    var isLongDistance: Bool { distanceMiles > 50 }
}

enum Season {
    case winter, spring, summer, fall
}

@Observable
final class GearRecommendationEngine {
    func recommendations(for conditions: TripConditions, ownedCategories: Set<String>) -> [GearRecommendation] {
        var recs: [GearRecommendation] = []

        // Always required
        recs += [
            .init(categoryName: "Shelter", categoryIcon: "tent", reason: "Essential protection from the elements.", priority: .required),
            .init(categoryName: "Sleep System", categoryIcon: "bed.double", reason: "You need sleep to keep moving.", priority: .required),
            .init(categoryName: "Water", categoryIcon: "drop", reason: "Filter and carry sufficient water.", priority: .required),
            .init(categoryName: "Navigation", categoryIcon: "map", reason: "Map, compass, or GPS for your route.", priority: .required),
            .init(categoryName: "First Aid", categoryIcon: "cross.case", reason: "Basic first aid for emergencies.", priority: .required),
            .init(categoryName: "Food", categoryIcon: "fork.knife", reason: "\(conditions.durationDays) days of meals needed.", priority: .required),
        ]

        // Elevation-based recommendations
        if conditions.isHighAlpine {
            recs.append(.init(
                categoryName: "Clothing",
                categoryIcon: "tshirt",
                reason: "Above 10,000 ft: expect cold temps, wind, and afternoon thunderstorms. Bring insulation layers.",
                priority: .required
            ))
            recs.append(.init(
                categoryName: "Sun Protection",
                categoryIcon: "sun.max",
                reason: "High UV exposure at altitude. Sunscreen, sunglasses, and sun hat are essential.",
                priority: .strongly
            ))
        }

        // Season-based recommendations
        switch conditions.season {
        case .winter:
            recs.append(.init(
                categoryName: "Clothing",
                categoryIcon: "tshirt",
                reason: "Winter temps require insulated layers, waterproof shell, and warm accessories.",
                priority: .required
            ))
            recs.append(.init(
                categoryName: "Tools & Repair",
                categoryIcon: "wrench.and.screwdriver",
                reason: "Winter: traction devices (microspikes/crampons) and an ice axe may be needed.",
                priority: .strongly
            ))
        case .spring:
            recs.append(.init(
                categoryName: "Clothing",
                categoryIcon: "tshirt",
                reason: "Spring weather is unpredictable — pack rain gear and a warm layer.",
                priority: .strongly
            ))
        case .summer:
            recs.append(.init(
                categoryName: "Hygiene",
                categoryIcon: "shower",
                reason: "Summer heat: extra electrolytes, bug protection, and sun protection recommended.",
                priority: .suggested
            ))
        case .fall:
            recs.append(.init(
                categoryName: "Clothing",
                categoryIcon: "tshirt",
                reason: "Fall temps drop fast at night. Bring a warm sleep layer and a puffy jacket.",
                priority: .strongly
            ))
        }

        // Terrain-based
        switch conditions.terrainType {
        case .desert:
            recs.append(.init(
                categoryName: "Water",
                categoryIcon: "drop",
                reason: "Desert terrain: carry extra water capacity (4L+). Water sources may be scarce.",
                priority: .required
            ))
        case .coastal:
            recs.append(.init(
                categoryName: "Clothing",
                categoryIcon: "tshirt",
                reason: "Coastal: damp, windy conditions. Bring a wind shell and moisture-wicking layers.",
                priority: .strongly
            ))
        case .alpine:
            recs.append(.init(
                categoryName: "Navigation",
                categoryIcon: "map",
                reason: "Alpine terrain: trails may be faint or snow-covered. GPS and topo map essential.",
                priority: .required
            ))
        default:
            break
        }

        // Extended trip recommendations
        if conditions.isExtendedTrip {
            recs.append(.init(
                categoryName: "Hygiene",
                categoryIcon: "shower",
                reason: "Multi-day trip: pack hygiene essentials including LNT waste kit.",
                priority: .strongly
            ))
            recs.append(.init(
                categoryName: "Electronics",
                categoryIcon: "bolt",
                reason: "Extended trip: consider a solar charger or extra battery pack.",
                priority: .suggested
            ))
        }

        if conditions.isLongDistance {
            recs.append(.init(
                categoryName: "Footwear",
                categoryIcon: "shoeprints.fill",
                reason: "Long distance: foot care is critical. Gaiters, blister kit, and trail runners.",
                priority: .strongly
            ))
        }

        return recs.sorted { $0.priority < $1.priority }
    }
}
