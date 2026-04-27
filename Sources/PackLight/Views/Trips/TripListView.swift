import SwiftUI
import SwiftData

struct TripListView: View {
    @Environment(TripViewModel.self) private var viewModel
    @Environment(\.modelContext) private var context
    @Query(sort: \Trip.startDate) private var allTrips: [Trip]

    var body: some View {
        @Bindable var vm = viewModel
        List {
            ForEach(viewModel.filtered(allTrips)) { trip in
                NavigationLink(destination: TripDetailView(trip: trip)) {
                    TripRow(trip: trip)
                }
            }
            .onDelete { offsets in
                offsets.map { viewModel.filtered(allTrips)[$0] }.forEach {
                    viewModel.deleteTrip($0, from: context)
                }
            }
        }
        .searchable(text: $vm.searchText, prompt: "Search trips")
        .navigationTitle("Trips")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add", systemImage: "plus") {
                    viewModel.showingAddTripSheet = true
                }
            }
        }
        .sheet(isPresented: $vm.showingAddTripSheet) {
            AddTripView()
        }
    }
}

private struct TripRow: View {
    let trip: Trip

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(trip.name).font(.headline)
            HStack {
                Text(trip.formattedDateRange)
                Spacer()
                Text(trip.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8).padding(.vertical, 2)
                    .background(.quaternary)
                    .clipShape(Capsule())
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            if trip.distanceMiles > 0 {
                Text(String(format: "%.1f miles · %@", trip.distanceMiles, trip.terrain.rawValue))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }
}
