import SwiftUI
import SwiftData

@main
struct PackLightApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            GearItem.self,
            Trip.self,
            PackList.self,
            PackListItem.self,
            ResupplyPoint.self,
            ResupplyPointItem.self,
        ])
    }
}
