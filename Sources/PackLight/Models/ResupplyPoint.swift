import Foundation
import SwiftData

@Model
final class ResupplyPoint {
    var id: UUID
    var locationName: String
    var mileMarker: Double
    var notes: String
    var shippingAddress: String
    var holdForPickup: Bool
    var estimatedArrivalDate: Date?
    var isSent: Bool
    var isPickedUp: Bool
    var createdAt: Date

    var trip: Trip?

    @Relationship(deleteRule: .cascade, inverse: \ResupplyPointItem.resupplyPoint)
    var items: [ResupplyPointItem] = []

    init(
        locationName: String,
        mileMarker: Double = 0,
        notes: String = "",
        shippingAddress: String = "",
        holdForPickup: Bool = false,
        estimatedArrivalDate: Date? = nil,
        trip: Trip? = nil
    ) {
        self.id = UUID()
        self.locationName = locationName
        self.mileMarker = mileMarker
        self.notes = notes
        self.shippingAddress = shippingAddress
        self.holdForPickup = holdForPickup
        self.estimatedArrivalDate = estimatedArrivalDate
        self.isSent = false
        self.isPickedUp = false
        self.createdAt = Date()
        self.trip = trip
    }

    var totalBoxWeightGrams: Double {
        items.reduce(0.0) { $0 + $1.lineWeightGrams }
    }

    var statusLabel: String {
        if isPickedUp { return "Picked Up" }
        if isSent { return "In Transit" }
        return "Preparing"
    }
}

@Model
final class ResupplyPointItem {
    var id: UUID
    var quantity: Int
    var notes: String
    var addedAt: Date

    var resupplyPoint: ResupplyPoint?
    var gearItem: GearItem?

    init(quantity: Int = 1, notes: String = "") {
        self.id = UUID()
        self.quantity = quantity
        self.notes = notes
        self.addedAt = Date()
    }

    var lineWeightGrams: Double {
        (gearItem?.weightGrams ?? 0) * Double(quantity)
    }
}
