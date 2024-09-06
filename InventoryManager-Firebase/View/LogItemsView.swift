//
//  LogItemsView.swift
//  InventoryManager-Firebase
//
//  Created by Israel on 9/1/24.
//

import SwiftUI
import FirebaseFirestore

struct LogItemsView: View {
    @Binding var scannedCode: String? // The barcode from the scanner
    @State private var selectedItemType: String = ""  // Default selection for item type
    @State private var assetTag: String = ""
    @State private var owner: String = ""  // Owner of the item (for computers)
    @State private var model: String = ""  // Model of the item (for monitors)
    @State private var serial: String = "" // Serial of the item (for other types)
    @State private var currentLocation: String = ""  // Current location of the item
    @State private var showingAlert = false
    @State private var collectionNames: [String] = ["Computer", "Monitor", "Server", "Switches", "iPads"]  // Collection names representing item types
    
    // Firestore reference
    let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            Form {
                // Section for Item Type Picker
                Section(header: Text("Item Type")) {
                    Picker("Select Item Type", selection: $selectedItemType) {  // Drop-down menu for item types
                        ForEach(collectionNames, id: \.self) { type in
                            Text(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())  // Display as a drop-down menu
                }

                // Section for Asset Details
                Section(header: Text("Asset Details")) {
                    TextField("Asset Tag", text: $assetTag)
                        .onAppear {
                            if let scanned = scannedCode {
                                self.assetTag = scanned
                                self.scannedCode = nil // Reset scannedCode after processing
                            }
                        }

                    TextField("Branch/Department", text: $currentLocation)
                }

                // Dynamic Section based on selected item type
                Section(header: Text(getDynamicFieldTitle())) {
                    if selectedItemType == "Computer" {
                        TextField("Owner", text: $owner)
                    } else if selectedItemType == "Monitor" {
                        TextField("Model", text: $model)
                    } else {
                        TextField("Serial Number", text: $serial)
                    }
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
            .onAppear {
                if let firstType = collectionNames.first {
                    self.selectedItemType = firstType
                }
            }
        }
    }

    // Determines the title for the dynamic field section
    private func getDynamicFieldTitle() -> String {
        switch selectedItemType {
        case "Computer":
            return "Owner Details"
        case "Monitor":
            return "Model Details"
        default:
            return "Serial Details"
        }
    }

    // Logs Item into Firebase
    private func logItem() {
        // Validation based on selected item type
        if assetTag.isEmpty || currentLocation.isEmpty || (selectedItemType == "Computer" && owner.isEmpty) || (selectedItemType == "Monitor" && model.isEmpty) || (selectedItemType != "Computer" && selectedItemType != "Monitor" && serial.isEmpty) {
            showingAlert = true
            return
        }

        // Determine check-in or check-out based on location
        let isCheckIn = (currentLocation == "DepartmentIT")
        var checkInOutData: [String: Any] = [
            "currentLocation": currentLocation,
        ]

        // Add dynamic field based on selected item type
        if selectedItemType == "Computer" {
            checkInOutData["owner"] = owner
        } else if selectedItemType == "Monitor" {
            checkInOutData["model"] = model
        } else {
            checkInOutData["serialNumber"] = serial
        }

        if isCheckIn {
            checkInOutData["checkIn"] = Date()
        } else {
            checkInOutData["checkOut"] = Date()
        }

        // Use the assetTag as the document ID in the selected collection
        db.collection(selectedItemType).document(assetTag).setData(checkInOutData, merge: true) { error in
            if let error = error {
                print("Error setting document: \(error.localizedDescription)")
            } else {
                print("Document successfully updated in the \(selectedItemType) collection with Asset Tag \(assetTag).")
                resetForm()
            }
        }
    }

    private func resetForm() {
        selectedItemType = collectionNames.first ?? "Computer"
        assetTag = ""
        currentLocation = ""
        owner = ""
        model = ""
        serial = ""
    }
}

struct LogItemsView_Previews: PreviewProvider {
    static var previews: some View {
        LogItemsView(scannedCode: .constant(nil))
    }
}
