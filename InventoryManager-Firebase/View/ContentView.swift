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
            // Barcode Scanner Tab
            BarcodeScannerView(scannedCode: $scannedCode, selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "barcode.viewfinder")
                    Text("Scan")
                }
                .tag(0) // Tag for the first tab

            // Log Items Tab, pass the scanned barcode
            LogItemsView(scannedCode: $scannedCode)
                .tabItem {
                    Image(systemName: "tray.and.arrow.down.fill")
                    Text("Log Items")
                }
                .tag(1) // Tag for the second tab (Log Items)

            // Dashboard Tab
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(2) // Add a tag for the third tab (Dashboard)

            // Inventory Data Tab
            InventoryDataView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Inventory")
                }
                .tag(3) // Add a tag for the fourth tab (Inventory)
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
