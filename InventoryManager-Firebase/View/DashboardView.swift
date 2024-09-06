//
//  DashboardView.swift
//  InventoryManager-Firebase
//
//  Created by Israel on 9/1/24.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Total Assets Section
                    VStack(alignment: .leading) {
                        Text("Total Assets")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.leading)

                        // Floating Pie Chart
                        PieChartView()
                            .frame(height: 250)  // Set a fixed height
                            .padding(.horizontal)
                    }

                    // Recent Activity Section
                    VStack(alignment: .leading) {
                        Text("Recent Activity")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.leading)

                        // Placeholder for recent activity items
                        ForEach(0..<5) { index in
                            HStack {
                                Text("Activity \(index + 1)")
                                    .padding(.leading)
                                Spacer()
                                Text(Date(), style: .time)
                                    .foregroundColor(.secondary)
                                    .padding(.trailing)
                            }
                            .padding(.vertical, 10)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("Dashboard")
        }
    }
}

// Floating Pie Chart without square box
struct PieChartView: View {
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)  // Use the smallest dimension
            let lineWidth = size * 0.25  // Adjust the stroke width relative to the view size
            
            ZStack {
                Circle()
                    .trim(from: 0.0, to: 0.7)  // First slice
                    .stroke(Color.blue, lineWidth: lineWidth)
                    .rotationEffect(.degrees(-90))  // Rotate to start from the top

                Circle()
                    .trim(from: 0.7, to: 1.0)  // Second slice
                    .stroke(Color.orange, lineWidth: lineWidth)
                    .rotationEffect(.degrees(-90))  // Rotate to align with the first slice

                Text("Total: 100")  // Placeholder for total assets
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            .frame(width: size, height: size)  // Constrain the circle within the available space
        }
    }
}

#Preview {
    DashboardView()
}
