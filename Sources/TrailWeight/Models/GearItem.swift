import Foundation
import SwiftData

@Model
final class GearItem {
    var id: UUID = UUID()
    var name: String = ""
    var brand: String = ""
    var categoryRawValue: String = GearCategory.other.rawValue
    var weightGrams: Double = 0
    var quantityOwned: Int = 1
    var isConsumable: Bool = false
    var notes: String = ""
    var purchaseURL: String = ""
    var imageURL: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .nullify, inverse: \PackListItem.gearItem)
    var packListItems: [PackListItem]?

    @Relationship(deleteRule: .nullify, inverse: \ResupplyPointItem.gearItem)
    var resupplyPointItems: [ResupplyPointItem]?

    var category: GearCategory {
        get { GearCategory(rawValue: categoryRawValue) ?? .other }
        set { categoryRawValue = newValue.rawValue }
    }

    init(
        name: String,
        brand: String = "",
        category: GearCategory = .other,
        weightGrams: Double = 0,
        quantityOwned: Int = 1,
        isConsumable: Bool = false,
        notes: String = "",
        purchaseURL: String = "",
        imageURL: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.brand = brand
        self.categoryRawValue = category.rawValue
        self.weightGrams = weightGrams
        self.quantityOwned = quantityOwned
        self.isConsumable = isConsumable
        self.notes = notes
        self.purchaseURL = purchaseURL
        self.imageURL = imageURL
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var weightOunces: Double { weightGrams * 0.035274 }
    var weightPounds: Double { weightGrams * 0.00220462 }

    var displayWeight: String {
        weightGrams >= 1000
            ? String(format: "%.2f kg", weightGrams / 1000)
            : String(format: "%.0f g", weightGrams)
    }
}
