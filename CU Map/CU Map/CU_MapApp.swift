import SwiftUI

@main
struct CU_MapApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainPage()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
