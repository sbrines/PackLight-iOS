import SwiftUI
import SwiftData

struct TripDetailView: View {
    @Bindable var trip: Trip
    @Environment(TripViewModel.self) private var viewModel
    @Environment(\.modelContext) private var context
    @State private var showingRecommendations = false

    private let recommendationEngine = GearRecommendationEngine()

    var body: some View {
        List {
            Section("Overview") {
                LabeledContent("Dates", value: trip.formattedDateRange)
                if trip.distanceMiles > 0 {
                    LabeledContent("Distance", value: String(format: "%.1f miles", trip.distanceMiles))
                }
                LabeledContent("Terrain", value: trip.terrain.rawValue)
                LabeledContent("Status", value: trip.status.rawValue)
            }

            if let packList = trip.packLists.first {
                Section("Pack List (\(packList.items.count) items)") {
                    NavigationLink("View & Edit Pack List") {
                        PackListView(packList: packList)
                    }
                    LabeledContent("Base Weight",
                                   value: WeightParser.displayString(packList.baseWeightGrams))
                    LabeledContent("Pack Weight",
                                   value: WeightParser.displayString(packList.packWeightGrams))
                }
            }

            Section("Resupply Points") {
                ForEach(trip.resupplyPoints.sorted { $0.mileMarker < $1.mileMarker }) { point in
                    NavigationLink(destination: ResupplyPointDetailView(point: point)) {
                        VStack(alignment: .leading) {
                            Text(point.locationName)
                            Text(String(format: "Mile %.1f · %@", point.mileMarker, point.statusLabel))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                Button("Add Resupply Point") {
                    viewModel.addResupplyPoint(to: trip, locationName: "New Point",
                                               mileMarker: 0, context: context)
                }
            }

            Section {
                Button("Gear Recommendations") {
                    showingRecommendations = true
                }
            }
        }
        .navigationTitle(trip.name)
        .sheet(isPresented: $showingRecommendations) {
            RecommendationsView(trip: trip)
        }
    }
}
