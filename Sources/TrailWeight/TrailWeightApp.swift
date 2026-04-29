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

    let container: ModelContainer = Self.makeContainer()

    private static func makeContainer() -> ModelContainer {
        let schema = Schema([
            GearItem.self,
            Trip.self,
            PackList.self,
            PackListItem.self,
            ResupplyPoint.self,
            ResupplyPointItem.self,
            WeightSnapshot.self,
        ])

        // In-memory store for unit tests — no persistence needed
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return makeMemoryContainer(schema: schema)
        }

        // CloudKit with local fallback
        let cloudConfig = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
        if let c = try? ModelContainer(for: schema, configurations: [cloudConfig]) { return c }

        let localConfig = ModelConfiguration(schema: schema)
        if let c = try? ModelContainer(for: schema, configurations: [localConfig]) { return c }

        return makeMemoryContainer(schema: schema)
    }

    private static func makeMemoryContainer(schema: Schema) -> ModelContainer {
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        guard let c = try? ModelContainer(for: schema, configurations: [config]) else {
            preconditionFailure("Unable to create ModelContainer")
        }
        return c
    }

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
