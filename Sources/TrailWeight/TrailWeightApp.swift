import SwiftUI
import SwiftData

@main
struct TrailWeightApp: App {

    @State private var appSettings = AppSettings()

    #if os(macOS)
    @State private var selectedSidebarItem: MacSidebarItem? = .gear
    @State private var gearVM = GearViewModel()
    @State private var tripVM = TripViewModel()
    #endif

    let container: ModelContainer = {
        let schema = Schema([
            GearItem.self,
            Trip.self,
            PackList.self,
            PackListItem.self,
            ResupplyPoint.self,
            ResupplyPointItem.self,
            WeightSnapshot.self,
        ])
        let config = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // CloudKit unavailable (no iCloud account) — fall back to local-only
            let localConfig = ModelConfiguration(schema: schema)
            return try! ModelContainer(for: schema, configurations: [localConfig])
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(container)
        .environment(appSettings)
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
