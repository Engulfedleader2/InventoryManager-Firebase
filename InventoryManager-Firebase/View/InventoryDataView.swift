//
//  InventoryDataView.swift
//  InventoryManager-Firebase
//
//  Created by Israel on 9/1/24.
//

import SwiftUI
import FirebaseFirestore

struct InventoryDataView: View {
    @State private var inventoryItems: [InventoryItem] = [] // State variable for production use
    private var db = Firestore.firestore()

    // Optional initializer for previews
    init(inventoryItems: [InventoryItem] = []) {
        _inventoryItems = State(initialValue: inventoryItems)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 1) {
                    ForEach(inventoryItems) { item in
                        InventoryBoxView(item: item)  // A reusable component for each box
                    }
                }
                .padding()
                .onAppear {
                    if inventoryItems.isEmpty {
                        listenToCollections() // Start listening to Firestore updates
                    }
                }
            }
            .navigationTitle("Inventory")
        }
    }

    // Function to listen to Firestore collections and update in real-time
    private func listenToCollections() {
        let collectionNames = ["Computer", "Monitor", "Server", "Switches", "iPads", "Gary"] // Define your collections in the desired order
        var items: [InventoryItem] = []

        for collectionName in collectionNames {
            db.collection(collectionName).addSnapshotListener { (snapshot, error) in
                if let error = error {
                    print("Error listening to collection \(collectionName): \(error.localizedDescription)")
                } else {
                    let documentCount = snapshot?.documents.count ?? 0
                    let newItem = InventoryItem(name: collectionName, quantity: documentCount)
                    
                    // Update or append item in inventory
                    DispatchQueue.main.async {
                        if let index = items.firstIndex(where: { $0.name == collectionName }) {
                            items[index] = newItem  // Update existing item
                        } else {
                            items.append(newItem)    // Add new item
                        }

                        // Sort items based on the order in collectionNames array
                        self.inventoryItems = items.sorted(by: {
                            collectionNames.firstIndex(of: $0.name) ?? 0 < collectionNames.firstIndex(of: $1.name) ?? 0
                        })
                    }
                }
            }
        }
    }
}

// Sample preview
#Preview {
    InventoryDataView(inventoryItems: [
        InventoryItem(name: "Computer", quantity: 10),
        InventoryItem(name: "Monitor", quantity: 15),
        InventoryItem(name: "Server", quantity: 5),
        InventoryItem(name: "Switches", quantity: 20),
        InventoryItem(name: "iPads", quantity: 12),
        InventoryItem(name: "Gary", quantity: 5)
    ])
}

struct InventoryBoxView: View {
    var item: InventoryItem
    
    var body: some View {
        ZStack {
            // Background color for all items
            backgroundColor(for: item.name)
                .cornerRadius(10)
                .shadow(radius: 2)

            // Conditional background image for "Gary"
            /*
            if item.name == "Gary" {
                Image("gary")  // Replace with your image name
                    .resizable()
                    .scaledToFill()
                    .opacity(0.2)  // Adjust opacity for subtle effect
                    .frame(height: 120)  // Ensure the image height matches the box
                    .clipShape(RoundedRectangle(cornerRadius: 10))  // Clip to match box shape
            }
            */
            
            // Box content
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
        }
        .frame(height: 120)  // Ensure consistent height for all boxes
        .padding()
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
        case "Gary":
            return Color(hex: "22C55E")  // Green color for Gary
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
