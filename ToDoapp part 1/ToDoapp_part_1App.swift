//
//  ToDoapp_part_1App.swift
//  ToDoapp part 1
//
//  Created by Артемий on 18.06.2024.
//

import SwiftUI
import SwiftData

@main
struct ToDoapp_part_1App: App {
    let fileCache = FileCache(todoItem: [])
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(fileCache)
        }
    }
}
