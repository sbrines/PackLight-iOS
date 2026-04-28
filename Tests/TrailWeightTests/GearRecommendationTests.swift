import XCTest
@testable import TrailWeight

final class GearRecommendationTests: XCTestCase {

    private let engine = GearRecommendationEngine()

    func testRequiredGearAlwaysPresent() {
        let conditions = TripConditions(
            maxElevationFeet: 5000,
            minElevationFeet: 3000,
            startDate: summerDate(),
            durationDays: 3,
            terrainType: .forest,
            distanceMiles: 20
        )
        let recs = engine.recommendations(for: conditions, ownedCategories: [])
        let required = recs.filter { $0.priority == .required }
        let requiredNames = Set(required.map { $0.categoryName })
        XCTAssertTrue(requiredNames.contains("Shelter"))
        XCTAssertTrue(requiredNames.contains("Water"))
        XCTAssertTrue(requiredNames.contains("Food"))
        XCTAssertTrue(requiredNames.contains("Navigation"))
    }

    func testAlpineElevationAddsClothing() {
        let conditions = TripConditions(
            maxElevationFeet: 12000,
            minElevationFeet: 8000,
            startDate: summerDate(),
            durationDays: 2,
            terrainType: .alpine,
            distanceMiles: 15
        )
        let recs = engine.recommendations(for: conditions, ownedCategories: [])
        let clothingRec = recs.first { $0.categoryName == "Clothing" }
        XCTAssertNotNil(clothingRec)
        XCTAssertTrue(clothingRec!.reason.contains("10,000"))
    }

    func testDesertTerrainRequiresExtraWater() {
        let conditions = TripConditions(
            maxElevationFeet: 3000,
            minElevationFeet: 1000,
            startDate: summerDate(),
            durationDays: 3,
            terrainType: .desert,
            distanceMiles: 30
        )
        let recs = engine.recommendations(for: conditions, ownedCategories: [])
        let waterRec = recs.filter { $0.categoryName == "Water" && $0.priority == .required }
        XCTAssertFalse(waterRec.isEmpty)
        XCTAssertTrue(waterRec.first?.reason.contains("Desert") ?? false)
    }

    func testExtendedTripAddsHygiene() {
        let conditions = TripConditions(
            maxElevationFeet: 5000,
            minElevationFeet: 3000,
            startDate: summerDate(),
            durationDays: 5,
            terrainType: .forest,
            distanceMiles: 40
        )
        let recs = engine.recommendations(for: conditions, ownedCategories: [])
        XCTAssertTrue(recs.contains { $0.categoryName == "Hygiene" })
    }

    func testRecommendationsSortedByPriority() {
        let conditions = TripConditions(
            maxElevationFeet: 5000,
            minElevationFeet: 3000,
            startDate: summerDate(),
            durationDays: 3,
            terrainType: .mixed,
            distanceMiles: 20
        )
        let recs = engine.recommendations(for: conditions, ownedCategories: [])
        let priorities = recs.map { $0.priority.rawValue }
        XCTAssertEqual(priorities, priorities.sorted(), "Recommendations should be sorted by priority")
    }

    // MARK: - Helpers

    private func summerDate() -> Date {
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 7
        comps.day = 15
        return Calendar.current.date(from: comps) ?? Date()
    }

    private func winterDate() -> Date {
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 1
        comps.day = 15
        return Calendar.current.date(from: comps) ?? Date()
    }
}
