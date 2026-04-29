import SwiftUI

struct SettingsView: View {
    @Environment(AppSettings.self) private var appSettings

    var body: some View {
        List {
            Section("Display Units") {
                Picker("Weight unit", selection: Binding(
                    get: { appSettings.weightUnit },
                    set: { appSettings.weightUnit = $0 }
                )) {
                    ForEach(WeightUnit.allCases) { unit in
                        Text(unitLabel(unit)).tag(unit)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            } footer: {
                Text("Applies everywhere weight is shown in the app.")
            }

            Section("About") {
                LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                Link("Privacy Policy", destination: URL(string: "https://sbrines.github.io/TrailWeight-Web/privacy.html")!)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }

    private func unitLabel(_ unit: WeightUnit) -> String {
        switch unit {
        case .grams:     return "Grams (g)"
        case .ounces:    return "Ounces (oz)"
        case .kilograms: return "Kilograms (kg)"
        case .pounds:    return "Pounds (lb)"
        }
    }
}
