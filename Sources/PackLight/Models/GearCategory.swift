import Foundation
import SwiftUI

enum GearCategory: String, CaseIterable, Codable, Identifiable {
    case shelter     = "Shelter"
    case sleep       = "Sleep"
    case clothing    = "Clothing"
    case cooking     = "Cooking"
    case navigation  = "Navigation"
    case firstAid    = "First Aid"
    case hygiene     = "Hygiene"
    case food        = "Food"
    case water       = "Water"
    case electronics = "Electronics"
    case footwear    = "Footwear"
    case tools       = "Tools & Repair"
    case other       = "Other"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .shelter:     return "tent"
        case .sleep:       return "bed.double.fill"
        case .clothing:    return "tshirt.fill"
        case .cooking:     return "flame.fill"
        case .navigation:  return "map.fill"
        case .firstAid:    return "cross.case.fill"
        case .hygiene:     return "shower.fill"
        case .food:        return "fork.knife"
        case .water:       return "drop.fill"
        case .electronics: return "bolt.fill"
        case .footwear:    return "shoeprints.fill"
        case .tools:       return "wrench.and.screwdriver.fill"
        case .other:       return "archivebox.fill"
        }
    }

    var color: Color {
        switch self {
        case .shelter:     return .indigo
        case .sleep:       return .purple
        case .clothing:    return .blue
        case .cooking:     return .orange
        case .navigation:  return .green
        case .firstAid:    return .red
        case .hygiene:     return .teal
        case .food:        return .yellow
        case .water:       return .cyan
        case .electronics: return .mint
        case .footwear:    return .brown
        case .tools:       return .gray
        case .other:       return .secondary
        }
    }

    var countsTowardBaseWeight: Bool {
        switch self {
        case .food, .water: return false
        default: return true
        }
    }
}
