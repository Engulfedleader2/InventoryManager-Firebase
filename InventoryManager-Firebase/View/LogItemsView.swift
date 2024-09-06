//
//  LogItemsView.swift
//  InventoryManager-Firebase
//
//  Created by Israel on 9/1/24.
//

import SwiftUI

struct LogItemsView: View {
    @Binding var scannedCode: String? // The barcode from the scanner
    @State private var selectedItemType: String = "Computer"  // Default selection for item type
    @State private var assetTag: String = ""
    @State private var owner: String = ""  // Owner of the item
    @State private var currentLocation: String = ""  // Current location of the item
    @State private var showingAlert = false

    let itemTypes = ["Computer", "Monitor", "Server", "Switches", "iPads"]  // Options for item types

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Type")) {
                    Picker("Select Item Type", selection: $selectedItemType) {  // Drop-down menu for item types
                        ForEach(itemTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())  // Display as a drop-down menu
                }

                Section(header: Text("Asset Details")) {
                    TextField("Asset Tag", text: $assetTag)
                        .onAppear {
                            if let scanned = scannedCode {
                                self.assetTag = scanned
                                self.scannedCode = nil // Reset scannedCode after processing
                            }
                        }

                    // Always show the current location field
                    TextField("Branch/Department", text: $currentLocation)
                }

                Section(header: Text("Owner Details")) {
                    TextField("Owner", text: $owner)  // New field for owner
                }

                Button(action: {
                    logItem()
                }) {
                    Text("Submit Item")
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Error"), message: Text("Please fill in all required fields."), dismissButton: .default(Text("OK")))
                }
            }
            .navigationTitle("Log New Item")
           
        }
    }

    private func logItem() {
        // Validation
        if assetTag.isEmpty || currentLocation.isEmpty || owner.isEmpty {
            showingAlert = true
            return
        }

        // Prepare the data for logging
        let itemData = [
            "itemType": selectedItemType,  // Selected item type
            "assetTag": assetTag,
            "currentLocation": currentLocation,
            "owner": owner,
            "checkInOutTime": Date()  // Automatically use the current time for check-in/out
        ] as [String : Any]

        print("Logged Item: \(itemData)")  // Replace with Firebase logic when implemented
        resetForm()  // Reset the form after logging
    }

    private func resetForm() {
        selectedItemType = "Computer"
        assetTag = ""
        currentLocation = ""
        owner = ""
    }
}

struct LogItemsView_Previews: PreviewProvider {
    static var previews: some View {
        LogItemsView(scannedCode: .constant(nil))
    }
}
