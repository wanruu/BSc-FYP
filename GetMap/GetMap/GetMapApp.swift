//
//  GetMapApp.swift
//  GetMap
//
//  Created by wanruuu on 24/10/2020.
//

import SwiftUI

@main
/* App struct primarily handles booting up the initial view, which is the ContentView by default */
struct GetMapApp: App {
    /* related to core data */
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
