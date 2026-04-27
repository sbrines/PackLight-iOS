import XCTest
@testable import PackLight

final class LighterpackServiceTests: XCTestCase {

    func testImportStandardCSV() throws {
        let csv = """
        Item Name,Category,desc,qty,weight,unit,url,price,worn,consumable
        Tarptent Stratospire Li,Shelter,,1,680,g,https://tarptent.com,0,0,0
        Enlightened Equipment Revelation,Sleep,,1,450,g,,0,0,0
        Trail runners,Footwear,,1,285,g,,0,1,0
        """
        let rows = try LighterpackService.import(csv: csv)
        XCTAssertEqual(rows.count, 3)
        XCTAssertEqual(rows[0].name, "Tarptent Stratospire Li")
        XCTAssertEqual(rows[0].weightGrams, 680, accuracy: 0.01)
        XCTAssertFalse(rows[0].consumable)
        XCTAssertTrue(rows[2].worn)
    }

    func testImportConvertsOuncesToGrams() throws {
        let csv = """
        Item Name,Category,desc,qty,weight,unit,url,price,worn,consumable
        Tent Stakes,Other,,6,0.4,oz,,0,0,0
        """
        let rows = try LighterpackService.import(csv: csv)
        XCTAssertEqual(rows[0].weightGrams, 0.4 * 28.3495, accuracy: 0.1)
    }

    func testImportHandlesQuotedCommas() throws {
        let csv = """
        Item Name,Category,desc,qty,weight,unit,url,price,worn,consumable
        "Knife, fork, spoon",Cooking,"Multi-use",1,45,g,,0,0,0
        """
        let rows = try LighterpackService.import(csv: csv)
        XCTAssertEqual(rows[0].name, "Knife, fork, spoon")
        XCTAssertEqual(rows[0].description, "Multi-use")
    }

    func testImportNoHeaderRow() throws {
        let csv = "Puffy Jacket,Clothing,,1,285,g,,0,1,0"
        let rows = try LighterpackService.import(csv: csv)
        XCTAssertEqual(rows.count, 1)
        XCTAssertTrue(rows[0].worn)
    }

    func testExportProducesValidCSV() {
        let item = GearItem(name: "Test Tent", category: .shelter, weightGrams: 700)
        let csv = LighterpackService.export(items: [item])
        XCTAssertTrue(csv.hasPrefix("Item Name,Category"))
        XCTAssertTrue(csv.contains("Test Tent"))
        XCTAssertTrue(csv.contains("700.00"))
        XCTAssertTrue(csv.contains(",g,"))
    }

    func testRoundTrip() throws {
        let original = GearItem(name: "Rain Jacket", category: .clothing,
                                 weightGrams: 320, isConsumable: false, notes: "My backup")
        let csv = LighterpackService.export(items: [original])
        let rows = try LighterpackService.import(csv: csv)
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].name, "Rain Jacket")
        XCTAssertEqual(rows[0].weightGrams, 320, accuracy: 0.01)
    }

    func testEmptyCSVThrows() {
        XCTAssertThrowsError(try LighterpackService.import(csv: "")) { error in
            XCTAssertTrue(error is LighterpackError)
        }
    }

    func testRowsToGearItems() throws {
        let csv = """
        Item Name,Category,desc,qty,weight,unit,url,price,worn,consumable
        Bear Canister,Other,BV500,1,992,g,,0,0,0
        """
        let rows = try LighterpackService.import(csv: csv)
        let items = LighterpackService.rowsToGearItems(rows)
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items[0].name, "Bear Canister")
        XCTAssertEqual(items[0].weightGrams, 992, accuracy: 0.01)
        XCTAssertEqual(items[0].notes, "BV500")
    }
}
