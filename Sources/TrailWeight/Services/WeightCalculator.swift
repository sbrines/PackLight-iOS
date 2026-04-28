import Foundation

struct CategoryWeight: Identifiable {
    let id = UUID()
    let categoryName: String
    let categoryIcon: String
    let weightGrams: Double
    let itemCount: Int
    var percentage: Double = 0
}

struct WeightSummary {
    let baseWeightGrams: Double
    let wornWeightGrams: Double
    let consumableWeightGrams: Double
    let totalWeightGrams: Double
    let byCategory: [CategoryWeight]

    var skinOutWeightGrams: Double { baseWeightGrams + wornWeightGrams }

    var classification: String {
        switch baseWeightGrams {
        case ..<2_270: return "Super Ultralight (SUL)"
        case ..<4_540: return "Ultralight (UL)"
        case ..<9_070: return "Lightweight"
        default:       return "Traditional"
        }
    }

    static var empty: WeightSummary {
        WeightSummary(baseWeightGrams: 0, wornWeightGrams: 0, consumableWeightGrams: 0,
                      totalWeightGrams: 0, byCategory: [])
    }
}

enum WeightCalculator {
    static func calculate(from items: [PackListItem]) -> WeightSummary {
        var base = 0.0, worn = 0.0, consumable = 0.0
        var categoryMap: [String: (icon: String, weight: Double, count: Int)] = [:]

        for item in items {
            guard let gear = item.gearItem else { continue }
            let w = gear.weightGrams * Double(item.packedQuantity)
            let catName = gear.category.rawValue
            let catIcon = gear.category.symbolName

            var entry = categoryMap[catName] ?? (icon: catIcon, weight: 0, count: 0)
            entry.weight += w
            entry.count += item.packedQuantity
            categoryMap[catName] = entry

            if item.isWorn {
                worn += w
            } else if gear.isConsumable {
                consumable += w
            } else {
                base += w
            }
        }

        let total = base + worn + consumable
        let cats = categoryMap.map { name, val in
            CategoryWeight(categoryName: name, categoryIcon: val.icon,
                           weightGrams: val.weight, itemCount: val.count,
                           percentage: total > 0 ? val.weight / total * 100 : 0)
        }.sorted { $0.weightGrams > $1.weightGrams }

        return WeightSummary(baseWeightGrams: base, wornWeightGrams: worn,
                             consumableWeightGrams: consumable, totalWeightGrams: total,
                             byCategory: cats)
    }
}
