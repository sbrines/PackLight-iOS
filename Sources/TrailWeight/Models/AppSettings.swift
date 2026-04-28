import SwiftUI

@Observable
final class AppSettings {
    @ObservationIgnored
    @AppStorage("weightUnit") private var _weightUnit: String = WeightUnit.ounces.rawValue

    var weightUnit: WeightUnit {
        get { WeightUnit(rawValue: _weightUnit) ?? .ounces }
        set { _weightUnit = newValue.rawValue }
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
