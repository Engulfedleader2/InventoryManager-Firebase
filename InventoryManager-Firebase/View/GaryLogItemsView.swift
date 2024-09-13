//
//  GaryLogItemsView.swift
//  InventoryManager-Firebase
//
//  Created by Israel on 9/9/24.
//

import SwiftUI
import FirebaseFirestore

struct GaryLogItemsView: View {
    @State private var assetTag: String = "" // The asset tag field for the Gary item
    @State private var model: String = ""  // Model of the item
    @State private var serial: String = "" // Serial number of the item
    @State private var itemType: String = "" // Type of item (e.g., Computer, Monitor, etc.)
    @State private var checkOutDate: Date = Date()  // Date of checkout
    @State private var showAdditionalFields = false  // Show additional fields if item doesn't exist
    @State private var showingAlert = false  // To handle alerts
    @State private var alertMessage = ""  // Custom alert message
    @State private var showCheckButton = true  // Toggle for the check button
    @State private var moveAssetConfirmation = false  // Toggle to show confirmation dialog for moving the asset
    @State private var currentCollection: String = "" // Store the original collection of the asset
    @State private var currentLocation: String = "" // Store the current location of the asset
    @State private var showScanner = false // To control the barcode scanner view
    @State private var scannedCode: String? // Scanned barcode value

    let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Log Gary Item")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.top, 20)

                    // Asset Tag input (required)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Asset Tag")
                            .font(.headline)
                            .foregroundColor(.gray)

                        HStack {
                            TextField("Enter or Scan Asset Tag", text: $assetTag)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                .onAppear {
                                    if let scanned = scannedCode {
                                        self.assetTag = scanned
                                        self.scannedCode = nil
                                    }
                                }

                            // Button to trigger barcode scanner
                            Button(action: {
                                showScanner = true // Show scanner when button is tapped
                            }) {
                                Image(systemName: "barcode.viewfinder")
                                    .font(.title)
                                    .padding(10)
                            }
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)

                    // Show Check button only if asset hasn't been checked yet
                    if showCheckButton {
                        Button(action: {
                            checkIfAssetExists()
                        }) {
                            Text("Check Asset")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                        }
                        .padding(.horizontal)
                    }

                    // Additional fields if the asset doesn't exist or after confirmation
                    if showAdditionalFields {
                        VStack(alignment: .leading, spacing: 10) {
                            // Model
                            Text("Model")
                                .font(.headline)
                                .foregroundColor(.gray)

                            TextField("Enter Model", text: $model)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .shadow(radius: 2)
                            
                            // Serial Number
                            Text("Serial Number")
                                .font(.headline)
                                .foregroundColor(.gray)

                            TextField("Enter Serial Number", text: $serial)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .shadow(radius: 2)

                            // Item Type
                            Text("Item Type")
                                .font(.headline)
                                .foregroundColor(.gray)

                            TextField("Enter Item Type (e.g., Computer, Monitor)", text: $itemType)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .shadow(radius: 2)

                            // Checkout Date (auto-set to current date)
                            HStack {
                                Text("Check Out Date:")
                                Text(checkOutDate, style: .date)
                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                        }
                        .padding(.horizontal)
                    }

                    // Submit Button for Gary Items
                    if showAdditionalFields {
                        Button(action: {
                            logGaryItem()
                        }) {
                            Text("Submit Gary Item")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
            .navigationTitle("Log Gary Items")
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $moveAssetConfirmation) {
                Alert(
                    title: Text("Move Asset"),
                    message: Text("This asset already exists in \(currentLocation). Do you want to move it to Gary?"),
                    primaryButton: .default(Text("Yes")) {
                        autofillFieldsAndMoveToGary()
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showScanner, onDismiss: {
                if let scanned = scannedCode {
                    self.assetTag = scanned // Autofill the asset tag
                    self.showScanner = false // Close scanner
                }
            }) {
                // Barcode scanner view
                BarcodeScannerView(scannedCode: $scannedCode, selectedTab: .constant(1))
            }
        }
    }

    // Check if the asset exists in any collection
    private func checkIfAssetExists() {
        guard !assetTag.isEmpty else {
            alertMessage = "Asset Tag cannot be empty."
            showingAlert = true
            return
        }

        let collections = ["Computer", "Monitor", "Server", "Switches", "iPads"]

        for collection in collections {
            db.collection(collection).document(assetTag).getDocument { document, error in
                if let error = error {
                    print("Error checking document in collection \(collection): \(error.localizedDescription)")
                } else if let document = document, document.exists {
                    // Asset exists, ask if the user wants to move it to Gary
                    self.currentLocation = document.data()?["currentLocation"] as? String ?? "Unknown"
                    self.currentCollection = collection
                    self.moveAssetConfirmation = true
                    return
                } else {
                    // Asset does not exist, show additional fields
                    showCheckButton = false  // Hide the check button after checking
                    showAdditionalFields = true
                }
            }
        }
    }

    // Autofill fields from the existing asset and allow user to move it to Gary
    private func autofillFieldsAndMoveToGary() {
        guard !assetTag.isEmpty else {
            alertMessage = "Asset Tag cannot be empty."
            showingAlert = true
            return
        }

        let documentRef = db.collection(currentCollection).document(assetTag)

        documentRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                let documentData = document.data() ?? [:]

                // Autofill fields based on existing data
                self.model = documentData["model"] as? String ?? ""
                self.serial = documentData["serialNumber"] as? String ?? ""
                self.itemType = self.currentCollection  // Set the type based on the original collection

                // Show the additional fields and allow the user to edit if necessary
                showCheckButton = false
                showAdditionalFields = true

                // Now, delete the old asset and move it to Gary
                moveAssetToGary(documentData: documentData)
            }
        }
    }

    private func moveAssetToGary(documentData: [String: Any]) {
        let documentRef = db.collection(currentCollection).document(assetTag)

        // Copy the document data to the Gary collection
        db.collection("Gary").document(assetTag).setData(documentData, merge: true) { error in
            if let error = error {
                print("Error moving asset to Gary: \(error.localizedDescription)")
            } else {
                // Delete the old asset from the original collection
                documentRef.delete { error in
                    if let error = error {
                        print("Error deleting document: \(error.localizedDescription)")
                    } else {
                        print("Asset moved to Gary and deleted from \(self.currentCollection).")
                    }
                }
            }
        }
    }

    // Log Gary item into Firestore
    private func logGaryItem() {
        // Validate required fields
        guard !model.isEmpty && !serial.isEmpty && !itemType.isEmpty else {
            alertMessage = "Please fill in all required fields."
            showingAlert = true
            return
        }

        let documentRef = db.collection("Gary").document(assetTag)

        // Prepare data for Gary collection
        let garyData: [String: Any] = [
            "model": model,
            "serialNumber": serial,
            "itemType": itemType,
            "checkOut": checkOutDate
        ]

        // Save the data in Firestore
        documentRef.setData(garyData, merge: true) { error in
            if let error = error {
                print("Error setting Gary document: \(error.localizedDescription)")
                alertMessage = "Failed to log item."
                showingAlert = true
            } else {
                print("Item successfully logged in Gary.")
                alertMessage = "Item successfully moved to Gary."
                showingAlert = true
                resetForm()
            }
        }
    }

    // Reset form after submission
    private func resetForm() {
        assetTag = ""
        model = ""
        serial = ""
        itemType = ""
        showAdditionalFields = false
        showCheckButton = true
    }
}

struct GaryLogItemsView_Previews: PreviewProvider {
    static var previews: some View {
        GaryLogItemsView()
    }
}
