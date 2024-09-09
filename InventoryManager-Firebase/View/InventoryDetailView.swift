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
    @State private var errorMessage: String? = nil
    
    let db = Firestore.firestore()

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)

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
                            DocumentCard(document: document, isExpanded: expandedDocuments.contains(document.documentID)) {
                                toggleExpansion(for: document.documentID)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .navigationTitle("\(collectionName) Documents")
            .onAppear {
                fetchCollectionDocuments()
            }
        }
    }
    
    private func fetchCollectionDocuments() {
        db.collection(collectionName).getDocuments { (snapshot, error) in
            if let error = error {
                self.errorMessage = "Error fetching documents: \(error.localizedDescription)"
                self.isLoading = false
                return
            }
            self.documents = snapshot?.documents ?? []
            self.isLoading = false
        }
    }
    
    private func toggleExpansion(for documentID: String) {
        if expandedDocuments.contains(documentID) {
            expandedDocuments.remove(documentID)
        } else {
            expandedDocuments.insert(documentID)
        }
    }
}

// Custom card for each document with full-width and improved design
struct DocumentCard: View {
    var document: QueryDocumentSnapshot
    var isExpanded: Bool
    var toggleExpandAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: toggleExpandAction) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.blue)
                        .rotationEffect(isExpanded ? .degrees(180) : .degrees(0))
                        .animation(.spring(), value: isExpanded)
                    
                    Text("Asset Tag: \(document.documentID)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)  // Full width
                .background(Color(.systemGray5).opacity(0.2)) // Subtle background
                .cornerRadius(10)
                .shadow(radius: 3)
            }

            if isExpanded {
                Divider()
                VStack(alignment: .leading) {
                    Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                        ForEach(document.data().sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            GridRow {
                                Text(key.capitalized + ":")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.secondary)
                                Text(formatValue(value))
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                            Divider()
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)  // Full width card
        .background(Color(.systemGray6))  // Subtle card background
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding(.vertical, 4)  // Spacing between cards
    }
    
    private func formatValue(_ value: Any) -> String {
        if let timestamp = value as? Timestamp {
            return DateFormatter.localizedString(from: timestamp.dateValue(), dateStyle: .short, timeStyle: .short)
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
}

#Preview {
    InventoryDetailView(collectionName: "Computer")
}
