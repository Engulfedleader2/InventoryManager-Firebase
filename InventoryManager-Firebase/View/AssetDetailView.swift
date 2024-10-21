//
//  AssetDetailsView.swift
//  InventoryManager-Firebase
//
//  Created by Israel on 10/19/24.
//

import SwiftUI

struct AssetDetailView: View {
    var activity: RecentActivity

    var body: some View {
        ZStack {
            // Add a gradient background to the detail view
            LinearGradient(gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                // Section for Asset Tag
                HStack {
                    Image(systemName: "tag.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 40))
                    
                    VStack(alignment: .leading) {
                        Text("Asset Tag")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(activity.assetTag)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding(.leading, 8)
                }
                .padding()
                .frame(maxWidth: .infinity)  // Full width
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5).opacity(0.6))
                )
                .padding(.horizontal)
                
                // Section for Collection
                HStack {
                    Image(systemName: "folder.fill")
                        .foregroundColor(.purple)
                        .font(.system(size: 40))
                    
                    VStack(alignment: .leading) {
                        Text("Collection")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(activity.collection)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .padding(.leading, 8)
                }
                .padding()
                .frame(maxWidth: .infinity)  // Full width
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5).opacity(0.6))
                )
                .padding(.horizontal)
                
                // Section for Check-In Info
                if let checkIn = activity.checkIn {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 40))
                        
                        VStack(alignment: .leading) {
                            Text("Checked In")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("\(checkIn, formatter: dateFormatter)")
                                .font(.title3)
                        }
                        .padding(.leading, 8)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)  // Full width
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5).opacity(0.6))
                    )
                    .padding(.horizontal)
                }
                
                // Section for Check-Out Info
                if let checkOut = activity.checkOut {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 40))
                        
                        VStack(alignment: .leading) {
                            Text("Checked Out")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("\(checkOut, formatter: dateFormatter)")
                                .font(.title3)
                        }
                        .padding(.leading, 8)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)  // Full width
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5).opacity(0.6))
                    )
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Asset Details")
            .padding(.top, 20)
        }
    }
}

// Date formatter for displaying dates
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

// Sample data for the preview
struct AssetDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleActivity = RecentActivity(
           // id: UUID(),
            assetTag: "Asset001",
            collection: "Computers",
            checkIn: Date(),
            checkOut: Date().addingTimeInterval(60 * 60 * 24)
        )
        AssetDetailView(activity: sampleActivity)
    }
}
