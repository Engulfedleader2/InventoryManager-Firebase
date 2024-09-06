//
//  InventoryDataView.swift
//  InventoryManager-Firebase
//
//  Created by Israel on 9/1/24.
//

import SwiftUI

struct InventoryDataView: View {
    // Local inventory items
    @State private var inventoryItems: [InventoryItem] = [
        InventoryItem(name: "Computers", quantity: 10, assetTag: "A001", location: "Warehouse"),
        InventoryItem(name: "Monitors", quantity: 15, assetTag: "M100", location: "Office"),
        InventoryItem(name: "Servers", quantity: 5, assetTag: "S200", location: "Data Center"),
        InventoryItem(name: "Switches", quantity: 20, assetTag: "SW300", location: "Network Room"),
        InventoryItem(name: "iPads", quantity: 12, assetTag: "IP400", location: "Office")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {  // Vertical stack with spacing between boxes
                    ForEach(inventoryItems) { item in
                        InventoryBoxView(item: item)  // A reusable component for each box
                    }
                }
                .padding()
            }
            .navigationTitle("Inventory")
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
                Spacer() // Push the button to the right
                Button(action: {
                    // More info button action
                    print("More info about \(item.name)")
                }) {
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
        .cornerRadius(10)  // Rounded corners
        .shadow(radius: 2)  // Optional shadow for the box
    }
    
    // Function to return the background color based on the item name
    private func backgroundColor(for title: String) -> Color {
        switch title {
        case "Computers":
            return Color(hex: "14B8A6")
        case "Monitors":
            return Color(hex: "EF4444")
        case "Servers":
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
    var assetTag: String? = nil
    var location: String? = nil
}

#Preview {
    InventoryDataView()
}
