//
//  InventoryDataView.swift
//  InventoryManager-Firebase
//
//  Created by Israel on 9/1/24.
//

import SwiftUI
import FirebaseFirestore

struct InventoryDataView: View {
    @State private var inventoryItems: [InventoryItem] = [] // This will store the collection names and document counts
    private var db = Firestore.firestore()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(inventoryItems) { item in
                        InventoryBoxView(item: item)  // A reusable component for each box
                    }
                }
                .padding()
                .onAppear {
                    fetchCollectionsData() // Fetch collection data from Firestore when the view appears
                }
            }
            .navigationTitle("Inventory")
        }
    }

    // Function to fetch Firestore collections and document counts
    private func fetchCollectionsData() {
        let collectionNames = ["Computer", "Monitor", "Server", "Switches", "iPads"] // Specify collection names
        var items: [InventoryItem] = Array(repeating: InventoryItem(name: "", quantity: 0), count: collectionNames.count) // Pre-fill array with placeholders
        
        let group = DispatchGroup()

        for (index, collectionName) in collectionNames.enumerated() {
            group.enter()  // Enter the group for each Firestore request
            db.collection(collectionName).getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching collection \(collectionName): \(error.localizedDescription)")
                } else {
                    let documentCount = snapshot?.documents.count ?? 0
                    items[index] = InventoryItem(name: collectionName, quantity: documentCount)  // Update the correct index
                }
                group.leave()  // Leave the group once the request completes
            }
        }

        // Notify when all Firestore calls have completed
        group.notify(queue: .main) {
            self.inventoryItems = items
        }
    }
}

// Custom view for each inventory box
struct InventoryBoxView: View {
    var item: InventoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(item.name)
                .font(.headline)
                .foregroundColor(.white)
            Text("Quantity: \(item.quantity)")
                .font(.subheadline)
                .foregroundColor(.white)
            HStack {
                Spacer()
                NavigationLink(destination: InventoryDetailView(collectionName: item.name)) {
                    Text("More Info")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .padding(8)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(5)
                }
            }
        }
        .padding()
        .background(backgroundColor(for: item.name))  // Custom background color based on item name
        .cornerRadius(10)
        .shadow(radius: 2)  // Optional shadow for the box
    }
    
    // Function to return the background color based on the item name
    private func backgroundColor(for title: String) -> Color {
        switch title {
        case "Computer":
            return Color(hex: "14B8A6")
        case "Monitor":
            return Color(hex: "EF4444")
        case "Server":
            return Color(hex: "3B82F6")
        case "Switches":
            return Color(hex: "F97316")
        case "iPads":
            return Color(hex: "A855F7")
        default:
            return Color(.systemGray6)  // Default color if title doesn't match
        }
    }
}

// Helper to convert hex code to Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Simple InventoryItem model for local storage
struct InventoryItem: Identifiable {
    let id = UUID()
    var name: String
    var quantity: Int
}

#Preview {
    InventoryDataView()
}
