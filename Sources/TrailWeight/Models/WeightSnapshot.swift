import Foundation
import SwiftData

// Records base weight at a point in time, enabling trend tracking across trips
@Model
final class WeightSnapshot {
    var id: UUID = UUID()
    var tripName: String = ""
    var baseWeightGrams: Double = 0
    var totalWeightGrams: Double = 0
    var itemCount: Int = 0
    var recordedAt: Date = Date()

    init(tripName: String, baseWeightGrams: Double, totalWeightGrams: Double, itemCount: Int) {
        self.id = UUID()
        self.tripName = tripName
        self.baseWeightGrams = baseWeightGrams
        self.totalWeightGrams = totalWeightGrams
        self.itemCount = itemCount
        self.recordedAt = Date()
    }

    var classification: String {
        switch baseWeightGrams {
        case ..<2_270: return "SUL"
        case ..<4_540: return "UL"
        case ..<9_070: return "Lightweight"
        default:       return "Traditional"
        }
    }
}
