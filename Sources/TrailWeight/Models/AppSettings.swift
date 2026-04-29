import Foundation

private let weightUnitKey = "weightUnit"

@Observable
final class AppSettings {
    var weightUnit: WeightUnit {
        didSet { UserDefaults.standard.set(weightUnit.rawValue, forKey: weightUnitKey) }
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: weightUnitKey) ?? ""
        weightUnit = WeightUnit(rawValue: stored) ?? .ounces
    }

    func format(_ grams: Double) -> String {
        switch weightUnit {
        case .grams:     return String(format: "%.0f g", grams)
        case .ounces:    return String(format: "%.1f oz", grams / 28.3495)
        case .kilograms: return String(format: "%.3f kg", grams / 1000)
        case .pounds:    return String(format: "%.2f lb", grams / 453.592)
        }
    }
}
