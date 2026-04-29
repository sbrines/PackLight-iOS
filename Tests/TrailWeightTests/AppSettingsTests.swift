import XCTest
@testable import TrailWeight

final class AppSettingsTests: XCTestCase {

    private let key = "weightUnit"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: key)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: key)
        super.tearDown()
    }

    func testDefaultsToOunces() {
        let settings = AppSettings()
        XCTAssertEqual(settings.weightUnit, .ounces)
    }

    func testPersistsUnitSelection() {
        let settings = AppSettings()
        settings.weightUnit = .grams
        let reloaded = AppSettings()
        XCTAssertEqual(reloaded.weightUnit, .grams)
    }

    func testFormatGrams() {
        let settings = AppSettings()
        settings.weightUnit = .grams
        XCTAssertEqual(settings.format(500), "500 g")
    }

    func testFormatOunces() {
        let settings = AppSettings()
        settings.weightUnit = .ounces
        XCTAssertEqual(settings.format(28.3495), "1.0 oz")
    }

    func testFormatKilograms() {
        let settings = AppSettings()
        settings.weightUnit = .kilograms
        XCTAssertEqual(settings.format(1000), "1.000 kg")
    }

    func testFormatPounds() {
        let settings = AppSettings()
        settings.weightUnit = .pounds
        XCTAssertEqual(settings.format(453.592), "1.00 lb")
    }

    func testFormatZero() {
        for unit in WeightUnit.allCases {
            let settings = AppSettings()
            settings.weightUnit = unit
            XCTAssertFalse(settings.format(0).isEmpty, "format(0) should not be empty for \(unit)")
        }
    }

    func testUnknownStoredValueFallsBackToOunces() {
        UserDefaults.standard.set("invalid_unit", forKey: key)
        let settings = AppSettings()
        XCTAssertEqual(settings.weightUnit, .ounces)
    }
}
