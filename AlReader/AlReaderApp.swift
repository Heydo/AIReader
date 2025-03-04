//
//  AlReaderApp.swift
//  AlReader
//
//  Created by 何玉栋 on 3/4/25.
//

import SwiftUI

@main
struct AlReaderApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
