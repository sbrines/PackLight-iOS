import XCTest
@testable import PackLight

final class WeightCalculatorTests: XCTestCase {

    func testEmptyPackList() {
        let summary = WeightCalculator.calculate(from: [])
        XCTAssertEqual(summary.baseWeightGrams, 0)
        XCTAssertEqual(summary.totalWeightGrams, 0)
        XCTAssertEqual(summary.byCategory.count, 0)
    }

    func testBaseWeightExcludesConsumablesAndWorn() {
        let shelter = makeItem(weight: 1000, isConsumable: false)
        let food    = makeItem(weight: 500, isConsumable: true)
        let jacket  = makeItem(weight: 300, isConsumable: false)

        let items = [
            makePackItem(gear: shelter, isWorn: false),
            makePackItem(gear: food, isWorn: false),
            makePackItem(gear: jacket, isWorn: true),
        ]

        let summary = WeightCalculator.calculate(from: items)

        XCTAssertEqual(summary.baseWeightGrams, 1000, "Shelter only")
        XCTAssertEqual(summary.wornWeightGrams, 300, "Jacket worn")
        XCTAssertEqual(summary.consumableWeightGrams, 500, "Food consumable")
        XCTAssertEqual(summary.totalWeightGrams, 1800)
        XCTAssertEqual(summary.skinOutWeightGrams, 1300, "Base + worn")
    }

    func testQuantityMultiplied() {
        let sock = makeItem(weight: 50)
        let item = makePackItem(gear: sock, quantity: 2)
        let summary = WeightCalculator.calculate(from: [item])
        XCTAssertEqual(summary.baseWeightGrams, 100)
    }

    func testClassificationUL() {
        // 4500g base ≈ 9.9 lbs — should be Ultralight
        let item = makePackItem(gear: makeItem(weight: 4500))
        let summary = WeightCalculator.calculate(from: [item])
        XCTAssertTrue(summary.classification.contains("Ultralight"))
    }

    func testClassificationSUL() {
        // 2000g base ≈ 4.4 lbs — should be Super Ultralight
        let item = makePackItem(gear: makeItem(weight: 2000))
        let summary = WeightCalculator.calculate(from: [item])
        XCTAssertTrue(summary.classification.contains("Super Ultralight"))
    }

    func testCategoryBreakdown() {
        let tent = makeItem(weight: 700, category: .shelter)
        let bag  = makeItem(weight: 800, category: .sleep)

        let items = [makePackItem(gear: tent), makePackItem(gear: bag)]
        let summary = WeightCalculator.calculate(from: items)

        XCTAssertEqual(summary.byCategory.count, 2)
        XCTAssertEqual(summary.byCategory.first?.weightGrams, 800, "Sleep should be heaviest")
    }

    func testCategoryPercentages() {
        let tent = makeItem(weight: 1000, category: .shelter)
        let bag  = makeItem(weight: 1000, category: .sleep)
        let items = [makePackItem(gear: tent), makePackItem(gear: bag)]
        let summary = WeightCalculator.calculate(from: items)
        for cat in summary.byCategory {
            XCTAssertEqual(cat.percentage, 50, accuracy: 0.1)
        }
    }

    // MARK: - Helpers

    private func makeItem(weight: Double, isConsumable: Bool = false,
                          category: GearCategory = .shelter) -> GearItem {
        GearItem(name: "Test Item", category: category,
                 weightGrams: weight, isConsumable: isConsumable)
    }

    private func makePackItem(gear: GearItem, quantity: Int = 1,
                              isWorn: Bool = false) -> PackListItem {
        let item = PackListItem(gearItem: gear, packedQuantity: quantity, isWorn: isWorn)
        return item
    }
}
