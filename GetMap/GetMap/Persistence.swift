//
//  Persistence.swift
//  GetMap
//
//  Created by wanruuu on 29/10/2020.
//

import CoreData

/* includes various properties */
struct PersistenceController {
    static let shared = PersistenceController()
    
    /* The preview property allows us to use the CoreData functionality inside preview simulators. */
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newBuilding = Building(context: viewContext)
            newBuilding.timestamp = Date()
            newBuilding.name_en = "test"
            newBuilding.latitude = 0
            newBuilding.longitude = 0
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    /* The container property is the heart of the PersistenceController, which performs many different operations for us in the background when we store and call data. */
    /* Most importantly, the container allows us to access the so-called viewContext, which serves as in an in-memory scratchpad where objects are created, fetched, updated, deleted, and saved back to the persistent store of the device where the app runs on. */
    let container: NSPersistentCloudKitContainer

    /* the container gets initialized */
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "GetMap")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
