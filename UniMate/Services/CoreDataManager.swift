//
//  CoreDataManager.swift
//  UniMate
//
//  Created by Sheky Cheung on 28/11/2024.
//
import CoreData
class CoreDataManager {
    static let shared = CoreDataManager()
    private let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    private init() {
        container = NSPersistentContainer(name: "ChatPreview")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Debug: CoreData Error: \(error)")
            }
        }
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Debug: Error saving context: \(error)")
            }
        }
    }
    
    func clearAllChatPreviews() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ChatPreviewEntity.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(batchDeleteRequest)
            saveContext()
        } catch {
            print("Debug: Error clearing chat previews: \(error)")
        }
    }
}
