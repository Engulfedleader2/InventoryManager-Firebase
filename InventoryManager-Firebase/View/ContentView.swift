//
//  ContentView.swift
//  InventoryManager-Firebase
//
//  Created by Israel on 8/29/24.
//

import SwiftUI

struct ContentView: View {
    @State private var scannedCode: String?
    @State private var selectedTab: Int = 0 // Track the currently selected tab

    var body: some View {
        TabView(selection: $selectedTab) {

            // Dashboard Tab (reordered to be the first tab)
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(0) // Tag for the first tab

            // Log Items Tab
            LogItemsView(scannedCode: $scannedCode)
                .tabItem {
                    Image(systemName: "tray.and.arrow.down.fill")
                    Text("Log Items")
                }
                .tag(1) // Tag for the second tab

            // Gary View Tab (added)
            GaryLogItemsView()
                .tabItem {
                    Image(systemName: "trash.fill")
                    Text("Gary Items")
                }
                .tag(2) // Tag for the third tab

            // Inventory Data Tab
            InventoryDataView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Inventory")
                }
                .tag(3) // Tag for the fourth tab
        }
        .onAppear {
            // Handle logic if needed when the view appears
            if let code = scannedCode {
                print("Scanned Code Available: \(code)")
                // You can process or pass the scanned code to other parts of the app
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
