//
//  UniMateApp.swift
//  UniMate
//
//  Created by Davis Wu on 21/11/2024.
//

import SwiftUI

@main
struct UniMateApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
