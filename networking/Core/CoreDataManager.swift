//
//  CoreDataManager.swift
//  networking
//
//  Created by Denys Nikolaichuk on 16.08.2021.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataBAse")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func getAllUsers(_ completionHandler: @escaping([User]) -> Void) {
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            let userEntities = try? UserEntity.all(viewContext)
            let users = userEntities?.map({ User(entity: $0)})
            completionHandler(users ?? [])
        }
    }
    
    func save(users: [User], _ completionHandler: @escaping() -> Void) {
        let context = persistentContainer.viewContext
        context.perform {
            for user in users {
                _ = try? UserEntity.findOrCreate(user, context: context)
            }
            try? context.save()
            
            completionHandler()
        }
    }
}
