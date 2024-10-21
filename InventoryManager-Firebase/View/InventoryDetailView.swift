//
//  InventoryDetailView.swift
//  InventoryManager-Firebase
//
//  Created by Israel on 9/6/24.
//

import SwiftUI
import FirebaseFirestore

struct InventoryDetailView: View {
    var collectionName: String
    @State private var documents: [QueryDocumentSnapshot] = []
    @State private var expandedDocuments: Set<String> = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    
    let db = Firestore.firestore()

    var body: some View {
        ZStack {
            // Professional background gradient for dark/light mode
            LinearGradient(gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
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
                            .transition(.slide)
                            .animation(.easeInOut, value: expandedDocuments)
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

struct DocumentCard: View {
    var document: QueryDocumentSnapshot
    var isExpanded: Bool
    var toggleExpandAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: toggleExpandAction) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.accentColor)
                        .rotationEffect(isExpanded ? .degrees(180) : .degrees(0))
                        .animation(.spring(), value: isExpanded)
                    
                    Text("Asset Tag: \(document.documentID)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    // Gradient background that looks good in both light and dark modes
                    LinearGradient(gradient: Gradient(colors: [Color(.systemGray5).opacity(0.3), Color(.systemGray4).opacity(0.6)]),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
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
                .transition(.opacity)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            // Adaptive background for dark/light mode
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.7))
        )
        .shadow(radius: 4, x: 0, y: 2)
        .padding(.vertical, 4)
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
