//
//  LogItemsView.swift
//  InventoryManager-Firebase
//
//  Created by Israel on 9/1/24.
//

import SwiftUI
import FirebaseFirestore
import Combine

struct LogItemsView: View {
    @Binding var scannedCode: String? // The barcode from the scanner
    @State private var selectedItemType: String = "Computer"  // Default selection for item type
    @State private var assetTag: String = ""
    @State private var owner: String = ""  // Owner of the item (for computers)
    @State private var model: String = ""  // Model of the item (for monitors)
    @State private var serial: String = "" // Serial of the item (for other types)
    @State private var currentLocation: String = ""  // Current location of the item
    @State private var showingAlert = false
    @State private var collectionNames: [String] = ["Computer", "Monitor", "Server", "Switches", "iPads"]

    @ObservedObject private var keyboardResponder = KeyboardResponder()

    let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Log New Item")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.top, 20)

                    // Item Type Picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Item Type")
                            .font(.headline)
                            .foregroundColor(.gray)

                        Picker("Select Item Type", selection: $selectedItemType) {
                            ForEach(collectionNames, id: \.self) { type in
                                Text(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    }
                    .padding(.horizontal)

                    // Asset Details Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Asset Tag")
                            .font(.headline)
                            .foregroundColor(.gray)

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

                        Text("Branch/Department")
                            .font(.headline)
                            .foregroundColor(.gray)

                        TextField("Enter Branch/Department", text: $currentLocation)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                    .padding(.horizontal)

                    // Dynamic Field based on selected item type
                    VStack(alignment: .leading, spacing: 10) {
                        Text(getDynamicFieldTitle())
                            .font(.headline)
                            .foregroundColor(.gray)

                        if selectedItemType == "Computer" {
                            TextField("Owner", text: $owner)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .shadow(radius: 2)
                        } else if selectedItemType == "Monitor" {
                            TextField("Model", text: $model)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .shadow(radius: 2)
                        } else {
                            TextField("Serial Number", text: $serial)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .shadow(radius: 2)
                        }
                    }
                    .padding(.horizontal)

                    // Submit Button
                    Button(action: {
                        logItem()
                    }) {
                        Text("Submit Item")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                    .padding(.horizontal)
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Error"), message: Text("Please fill in all required fields."), dismissButton: .default(Text("OK")))
                    }

                    Spacer()
                }
                .padding(.bottom, keyboardResponder.currentHeight)  // Adjust padding based on keyboard height
                .animation(.easeInOut)  // Smooth animation when keyboard appears/disappears
                .onTapGesture {
                    // Dismiss the keyboard when tapping anywhere outside the text fields
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
            .navigationTitle("Log Items")
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }

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

    private func logItem() {
        // Validation based on selected item type
        if assetTag.isEmpty || currentLocation.isEmpty || (selectedItemType == "Computer" && owner.isEmpty) || (selectedItemType == "Monitor" && model.isEmpty) || (selectedItemType != "Computer" && selectedItemType != "Monitor" && serial.isEmpty) {
            showingAlert = true
            return
        }

        // Reference to the document in Firestore
        let documentRef = db.collection(selectedItemType).document(assetTag)

        // Check if the document already exists
        documentRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                // If document exists, print a message and exit
                print("Item already exists in the database with Asset Tag: \(self.assetTag)")
            } else {
                // If document does not exist, proceed to log the item
                self.saveNewItem(documentRef: documentRef)
            }
        }
    }

    private func saveNewItem(documentRef: DocumentReference) {
        // Determine check-in or check-out based on location
        let isCheckIn = (currentLocation == "DepartmentIT")
        var checkInOutData: [String: Any] = ["currentLocation": currentLocation]

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

        // Save the new item to Firestore
        documentRef.setData(checkInOutData, merge: true) { error in
            if let error = error {
                print("Error setting document: \(error.localizedDescription)")
            } else {
                print("Document successfully added to the \(self.selectedItemType) collection with Asset Tag \(self.assetTag).")
                self.resetForm()
            }
        }
    }

    private func resetForm() {
        selectedItemType = "Computer"
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
