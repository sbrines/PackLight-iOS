import SwiftUI
import SwiftData

#if os(macOS)

enum MacSidebarItem: String, CaseIterable, Identifiable {
    case gear   = "Gear Inventory"
    case trips  = "Trips"
    case weight = "Weight"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .gear:   return "backpack.fill"
        case .trips:  return "map.fill"
        case .weight: return "scalemass.fill"
        }
    }
}

struct MacContentView: View {
    @Environment(GearViewModel.self) private var gearViewModel
    @Environment(TripViewModel.self) private var tripViewModel
    @Environment(WeightViewModel.self) private var weightViewModel

    @State private var selectedItem: MacSidebarItem? = .gear

    var body: some View {
        NavigationSplitView {
            List(MacSidebarItem.allCases, selection: $selectedItem) { item in
                Label(item.rawValue, systemImage: item.icon)
                    .tag(item)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 220)
            .listStyle(.sidebar)
            .navigationTitle("TrailWeight")
        } detail: {
            NavigationStack {
                switch selectedItem {
                case .gear, nil:
                    GearListView()
                        .environment(gearViewModel)
                case .trips:
                    TripListView()
                        .environment(tripViewModel)
                case .weight:
                    WeightDashboardView()
                        .environment(weightViewModel)
                }
            }
        }
    }
}

// MARK: - Mac Commands (attached at Scene level in TrailWeightApp)

struct TrailWeightCommands: Commands {
    @Binding var selectedItem: MacSidebarItem?
    let gearVM: GearViewModel
    let tripVM: TripViewModel

    var body: some Commands {
        CommandMenu("TrailWeight") {
            Button("New Gear Item") {
                selectedItem = .gear
                gearVM.showingAddSheet = true
            }
            .keyboardShortcut("n", modifiers: .command)

            Button("New Trip") {
                selectedItem = .trips
                tripVM.showingAddTripSheet = true
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])
        }

        CommandGroup(replacing: .sidebar) {
            Button("Gear Inventory") { selectedItem = .gear }
                .keyboardShortcut("1", modifiers: .command)
            Button("Trips") { selectedItem = .trips }
                .keyboardShortcut("2", modifiers: .command)
            Button("Weight") { selectedItem = .weight }
                .keyboardShortcut("3", modifiers: .command)
        }
    }
}

#endif
