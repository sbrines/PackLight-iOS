import Foundation
import SwiftData

@Model
final class PackList {
    var id: UUID
    var name: String
    var notes: String
    var createdAt: Date

    var trip: Trip?

    @Relationship(deleteRule: .cascade, inverse: \PackListItem.packList)
    var items: [PackListItem] = []

    init(name: String, notes: String = "", trip: Trip? = nil) {
        self.id = UUID()
        self.name = name
        self.notes = notes
        self.trip = trip
        self.createdAt = Date()
    }

    var totalWeightGrams: Double {
        items.reduce(0.0) { sum, item in
            sum + (item.gearItem?.weightGrams ?? 0) * Double(item.packedQuantity)
        }
    }

    var baseWeightGrams: Double {
        items.reduce(0.0) { sum, item in
            let isConsumable = item.gearItem?.isConsumable ?? false
            guard !isConsumable && !item.isWorn else { return sum }
            return sum + (item.gearItem?.weightGrams ?? 0) * Double(item.packedQuantity)
        }
    }

    var packWeightGrams: Double {
        items.reduce(0.0) { sum, item in
            guard !item.isWorn else { return sum }
            return sum + (item.gearItem?.weightGrams ?? 0) * Double(item.packedQuantity)
        }
    }

    var wornWeightGrams: Double {
        items.reduce(0.0) { sum, item in
            guard item.isWorn else { return sum }
            return sum + (item.gearItem?.weightGrams ?? 0) * Double(item.packedQuantity)
        }
    }
}
