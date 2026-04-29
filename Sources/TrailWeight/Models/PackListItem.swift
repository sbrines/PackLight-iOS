import Foundation
import SwiftData

@Model
final class PackListItem {
    var id: UUID = UUID()
    var packedQuantity: Int = 1
    var isWorn: Bool = false
    var notes: String = ""
    var sortOrder: Int = 0

    var packList: PackList?
    var gearItem: GearItem?

    init(gearItem: GearItem? = nil, packList: PackList? = nil, packedQuantity: Int = 1, isWorn: Bool = false, sortOrder: Int = 0) {
        self.id = UUID()
        self.gearItem = gearItem
        self.packList = packList
        self.packedQuantity = packedQuantity
        self.isWorn = isWorn
        self.notes = ""
        self.sortOrder = sortOrder
    }

    var totalWeightGrams: Double {
        (gearItem?.weightGrams ?? 0) * Double(packedQuantity)
    }

    var totalWeightOunces: Double {
        totalWeightGrams / 28.3495
    }
}
