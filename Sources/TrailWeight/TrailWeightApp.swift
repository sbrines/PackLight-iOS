import SwiftUI
import SwiftData

@main
struct TrailWeightApp: App {

    #if os(macOS)
    @State private var selectedSidebarItem: MacSidebarItem? = .gear
    @State private var gearVM = GearViewModel()
    @State private var tripVM = TripViewModel()
    #endif

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: [
            GearItem.self,
            Trip.self,
            PackList.self,
            PackListItem.self,
            ResupplyPoint.self,
            ResupplyPointItem.self,
            WeightSnapshot.self,
        ])
        #if os(macOS)
        .commands {
            TrailWeightCommands(
                selectedItem: $selectedSidebarItem,
                gearVM: gearVM,
                tripVM: tripVM
            )
        }
        .defaultSize(width: 1000, height: 700)
        #endif
    }
}
