//
//  InventoryDetailView.swift
//  InventoryManager-Firebase
//
//  Created by Israel on 9/6/24.
//

import SwiftUI
import FirebaseFirestore

// View to display all documents in the selected collection with expandable rows
struct InventoryDetailView: View {
    var collectionName: String // The name of the Firestore collection
    @State private var documents: [QueryDocumentSnapshot] = [] // List of Firestore documents
    @State private var expandedDocuments: Set<String> = [] // Track expanded documents by their documentID
    @State private var isLoading = true // Loading state
    @State private var errorMessage: String? = nil // To display error messages

    // Firestore reference
    let db = Firestore.firestore()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if isLoading {
                    ProgressView("Loading documents...")
                        .font(.title2)
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .font(.title3)
                        .padding()
                } else {
                    ForEach(documents, id: \.documentID) { document in
                        VStack(alignment: .leading, spacing: 8) {
                            // Asset Tag (click to expand/collapse)
                            Button(action: {
                                toggleExpansion(for: document.documentID)
                            }) {
                                HStack {
                                    Image(systemName: expandedDocuments.contains(document.documentID) ? "chevron.down" : "chevron.right")
                                        .foregroundColor(.blue)
                                    Text("Asset Tag: \(document.documentID)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                }
                            }

                            // Conditionally show the details if expanded
                            if expandedDocuments.contains(document.documentID) {
                                Divider()
                                
                                // Table for the key-value pairs
                                VStack(alignment: .leading) {
                                    Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                                        ForEach(document.data().sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                            GridRow {
                                                Text(key.capitalized + ":")
                                                    .font(.subheadline)
                                                    .bold()
                                                Text(formatValue(value))
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                            Divider() // Line to visually separate rows
                                        }
                                    }
                                }
                                .padding(.top, 8) // Remove background, add top padding for spacing
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.top)
        }
        .background(Color(.systemGroupedBackground)) // Background color
        .navigationTitle("\(collectionName) Documents")
        .onAppear {
            fetchCollectionDocuments() // Fetch the documents when the view appears
        }
    }

    // Function to fetch all documents in the collection
    private func fetchCollectionDocuments() {
        db.collection(collectionName).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                self.errorMessage = "Error fetching documents: \(error.localizedDescription)"
                self.isLoading = false
                return
            }
            
            if let snapshot = snapshot {
                self.documents = snapshot.documents // Save the fetched documents
            } else {
                self.errorMessage = "No documents found."
            }
            
            self.isLoading = false
        }
    }

    // Function to format values for display
    private func formatValue(_ value: Any) -> String {
        if let timestamp = value as? Timestamp {
            return timestamp.dateValue().description
        } else if let value = value as? String {
            return value
        } else if let value = value as? Int {
            return "\(value)"
        } else if let value = value as? Double {
            return "\(value)"
        } else {
            return "N/A"
        }
    }

    // Toggle the expansion state of a document
    private func toggleExpansion(for documentID: String) {
        if expandedDocuments.contains(documentID) {
            expandedDocuments.remove(documentID) // Collapse
        } else {
            expandedDocuments.insert(documentID) // Expand
        }
    }
}

// Sample preview for the InventoryDetailView
#Preview {
    InventoryDetailView(collectionName: "Computers")
}
