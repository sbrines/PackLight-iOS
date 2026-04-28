import Foundation
import SwiftData

enum TerrainType: String, Codable, CaseIterable, Identifiable {
    case alpine  = "Alpine"
    case desert  = "Desert"
    case forest  = "Forest"
    case coastal = "Coastal"
    case canyon  = "Canyon"
    case tundra  = "Tundra"
    case mixed   = "Mixed"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .alpine:  return "mountain.2.fill"
        case .desert:  return "sun.max.fill"
        case .forest:  return "tree.fill"
        case .coastal: return "water.waves"
        case .canyon:  return "triangle.fill"
        case .tundra:  return "snowflake"
        case .mixed:   return "map"
        }
    }
}

enum TripStatus: String, Codable, CaseIterable, Identifiable {
    case planning   = "Planning"
    case upcoming   = "Upcoming"
    case inProgress = "In Progress"
    case completed  = "Completed"
    case cancelled  = "Cancelled"

    var id: String { rawValue }
}

@Model
final class Trip {
    var id: UUID
    var name: String
    var notes: String
    var trailName: String
    var startLocation: String
    var endLocation: String
    var startDate: Date?
    var endDate: Date?
    var distanceMiles: Double
    var maxElevationFeet: Int
    var minElevationFeet: Int
    var terrainRawValue: String
    var statusRawValue: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \PackList.trip)
    var packLists: [PackList] = []

    @Relationship(deleteRule: .cascade, inverse: \ResupplyPoint.trip)
    var resupplyPoints: [ResupplyPoint] = []

    var terrain: TerrainType {
        get { TerrainType(rawValue: terrainRawValue) ?? .mixed }
        set { terrainRawValue = newValue.rawValue }
    }

    var status: TripStatus {
        get { TripStatus(rawValue: statusRawValue) ?? .planning }
        set { statusRawValue = newValue.rawValue }
    }

    init(
        name: String,
        notes: String = "",
        trailName: String = "",
        startLocation: String = "",
        endLocation: String = "",
        startDate: Date? = nil,
        endDate: Date? = nil,
        distanceMiles: Double = 0,
        maxElevationFeet: Int = 0,
        minElevationFeet: Int = 0,
        terrain: TerrainType = .mixed
    ) {
        self.id = UUID()
        self.name = name
        self.notes = notes
        self.trailName = trailName
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.startDate = startDate
        self.endDate = endDate
        self.distanceMiles = distanceMiles
        self.maxElevationFeet = maxElevationFeet
        self.minElevationFeet = minElevationFeet
        self.terrainRawValue = terrain.rawValue
        self.statusRawValue = TripStatus.planning.rawValue
        self.createdAt = Date()
    }

    var durationDays: Int {
        guard let start = startDate, let end = endDate else { return 1 }
        return max(1, Calendar.current.dateComponents([.day], from: start, to: end).day ?? 1)
    }

    var formattedDateRange: String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .none
        switch (startDate, endDate) {
        case let (s?, e?): return "\(fmt.string(from: s)) – \(fmt.string(from: e))"
        case let (s?, nil): return "Starts \(fmt.string(from: s))"
        default: return "Dates TBD"
        }
    }
}
