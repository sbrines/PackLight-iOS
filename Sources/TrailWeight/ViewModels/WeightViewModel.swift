import Foundation
import Observation

enum WeightUnit: String, CaseIterable, Identifiable {
    case grams     = "g"
    case ounces    = "oz"
    case kilograms = "kg"
    case pounds    = "lb"

    var id: String { rawValue }
}

@Observable
final class WeightViewModel {
    var selectedTrip: Trip? = nil
    var summary: WeightSummary = .empty
    var displayUnit: WeightUnit = .ounces

    func recalculate() {
        guard let items = selectedTrip?.packLists?.first?.items else {
            summary = .empty
            return
        }
        summary = WeightCalculator.calculate(from: items)
    }

    func formatted(_ grams: Double) -> String {
        switch displayUnit {
        case .grams:      return String(format: "%.0f g", grams)
        case .ounces:     return String(format: "%.1f oz", grams / 28.3495)
        case .kilograms:  return String(format: "%.3f kg", grams / 1000)
        case .pounds:     return String(format: "%.2f lb", grams / 453.592)
        }
    }
}
