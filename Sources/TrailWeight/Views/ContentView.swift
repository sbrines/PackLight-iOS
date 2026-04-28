import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var gearViewModel = GearViewModel()
    @State private var tripViewModel = TripViewModel()
    @State private var weightViewModel = WeightViewModel()

    var body: some View {
        #if os(macOS)
        MacContentView()
            .environment(gearViewModel)
            .environment(tripViewModel)
            .environment(weightViewModel)
        #else
        TabView {
            NavigationStack {
                GearListView()
            }
            .tabItem { Label("Gear", systemImage: "backpack.fill") }
            .environment(gearViewModel)

            NavigationStack {
                TripListView()
            }
            .tabItem { Label("Trips", systemImage: "map.fill") }
            .environment(tripViewModel)

            NavigationStack {
                WeightDashboardView()
            }
            .tabItem { Label("Weight", systemImage: "scalemass.fill") }
            .environment(weightViewModel)

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        #endif
    }
}
