//
//  CoreDataViewModel.swift
//  Memorizing
//
//  Created by 이종현 on 2023/01/31.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let instance = CoreDataManager()
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer(name: "")
        container.loadPersistentStores { decription, error in
            if let error {
                print("Error occured. \(error.localizedDescription)")
            }
        }
        context = container.viewContext
    }
    
    func save() {
        do {
            try context.save()
        } catch {
            print("Error occured in saving. \(error.localizedDescription)")
        }
    }
}

class CoreDataViewModel: ObservableObject {
    let manager = CoreDataManager.instance
    
    @Published var notes: [Note
}
