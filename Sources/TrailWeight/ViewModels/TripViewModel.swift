import Foundation
import SwiftData
import Observation

@Observable
final class TripViewModel {
    var showingAddTripSheet = false
    var selectedTrip: Trip? = nil
    var searchText = ""
    var filterStatus: TripStatus? = nil

    func filtered(_ trips: [Trip]) -> [Trip] {
        var result = trips
        if let status = filterStatus {
            result = result.filter { $0.status == status }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.trailName.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result.sorted { ($0.startDate ?? .distantFuture) < ($1.startDate ?? .distantFuture) }
    }

    @discardableResult
    func createTrip(name: String, in context: ModelContext) -> Trip {
        let trip = Trip(name: name)
        let packList = PackList(name: "\(name) — Pack List")
        packList.trip = trip
        context.insert(trip)
        context.insert(packList)
        try? context.save()
        return trip
    }

    func deleteTrip(_ trip: Trip, from context: ModelContext) {
        context.delete(trip)
        try? context.save()
    }

    @discardableResult
    func addGearItem(_ gear: GearItem, to packList: PackList, quantity: Int = 1,
                     isWorn: Bool = false, context: ModelContext) -> PackListItem {
        if let existing = (packList.items ?? []).first(where: { $0.gearItem?.id == gear.id }) {
            existing.packedQuantity = min(existing.packedQuantity + quantity, gear.quantityOwned)
            try? context.save()
            return existing
        }
        let item = PackListItem(gearItem: gear, packList: packList,
                                packedQuantity: min(quantity, gear.quantityOwned), isWorn: isWorn)
        packList.items = (packList.items ?? []) + [item]
        context.insert(item)
        try? context.save()
        return item
    }

    func removeItem(_ item: PackListItem, from packList: PackList, context: ModelContext) {
        packList.items?.removeAll { $0.id == item.id }
        context.delete(item)
        try? context.save()
    }

    @discardableResult
    func addResupplyPoint(to trip: Trip, locationName: String,
                          mileMarker: Double, context: ModelContext) -> ResupplyPoint {
        let point = ResupplyPoint(locationName: locationName, mileMarker: mileMarker, trip: trip)
        trip.resupplyPoints = (trip.resupplyPoints ?? []) + [point]
        context.insert(point)
        try? context.save()
        return point
    }
}
