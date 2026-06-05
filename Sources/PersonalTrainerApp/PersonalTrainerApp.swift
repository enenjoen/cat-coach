import SwiftUI

@main
struct PersonalTrainerApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(store)
                .frame(minWidth: 1008, minHeight: 684)
        }
        .windowStyle(.titleBar)
        .commands {
            SidebarCommands()
        }
    }
}
