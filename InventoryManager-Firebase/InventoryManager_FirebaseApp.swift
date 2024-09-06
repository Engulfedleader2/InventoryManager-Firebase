//
//  InventoryManager_FirebaseApp.swift
//  InventoryManager-Firebase
//
//  Created by Israel on 8/29/24.
//

import SwiftUI
import Firebase

@main
struct InventoryManager_FirebaseApp: App {

    // Initialize Firebase
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
