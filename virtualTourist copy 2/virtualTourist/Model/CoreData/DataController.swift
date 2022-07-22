//
//  DataController.swift
//  virtualTourist
//
//  Created by Oladele Abimbola on 6/26/22.
//

import Foundation
import CoreData

// MARK: Core Data Stack
class DataController{
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    init(modelName: String){
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completionHandler:(()->Void)? = nil){
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else{
                fatalError("\(error?.localizedDescription)")
            }
//            self.autoSaveContext()
            completionHandler?()
        }
    }
}

// MARK: Auto-Saving
//extension DataController{
//    func autoSaveContext(interval:TimeInterval = 20){
//        print("Autosaving context")
//        guard interval > 0 else{
//            print("cannot set negative autosave interval")
//            return
//        }
//        if viewContext.hasChanges{
//            try? viewContext.save()
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
//            self.autoSaveContext(interval: interval)
//        }
//    }
//}
