import SwiftUI

struct ResupplyPointDetailView: View {
    @Bindable var point: ResupplyPoint
    @Environment(\.modelContext) private var context
    @Environment(AppSettings.self) private var appSettings

    var body: some View {
        List {
            Section("Location") {
                TextField("Location name", text: $point.locationName)
                LabeledContent("Mile Marker", value: String(format: "%.1f", point.mileMarker))
            }
            Section("Status") {
                Toggle("Sent", isOn: $point.isSent)
                Toggle("Picked Up", isOn: $point.isPickedUp)
            }
            Section("Shipping") {
                TextField("Shipping address", text: $point.shippingAddress, axis: .vertical)
                Toggle("Hold for Pickup", isOn: $point.holdForPickup)
            }
            Section("Contents (\((point.items ?? []).count) items)") {
                ForEach(point.items ?? []) { item in
                    HStack {
                        Text(item.gearItem?.name ?? "Unknown")
                        Spacer()
                        Text("×\(item.quantity)")
                            .foregroundStyle(.secondary)
                        Text(appSettings.format(item.lineWeightGrams))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }
            if !point.notes.isEmpty || true {
                Section("Notes") {
                    TextEditor(text: $point.notes).frame(minHeight: 60)
                }
            }
        }
        .navigationTitle(point.locationName)
    }
}
