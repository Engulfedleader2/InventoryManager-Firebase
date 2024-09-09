//
//  DashboardView.swift
//  InventoryManager-Firebase
//
//  Created by Israel on 9/1/24.
//

import SwiftUI
import FirebaseFirestore

struct DashboardView: View {
    @State private var totalAssets: Int = 0
    @State private var recentActivities: [RecentActivity] = []  // Store recent activities
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Total Assets Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Assets")
                            .font(.headline)
                            .padding(.leading)

                        if let errorMessage = errorMessage {
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.red)
                                .padding()
                        } else if isLoading {
                            ProgressView("Loading data...")
                                .padding()
                        } else {
                            HStack {
                                Spacer()
                                Text("\(totalAssets)")
                                    .font(.system(size: 60, weight: .bold, design: .rounded))
                                    .padding()
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    .padding(.horizontal)

                    // Recent Activity Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Activity")
                            .font(.headline)
                            .padding(.leading)

                        if recentActivities.isEmpty {
                            Text("No recent activity.")
                                .foregroundColor(.secondary)
                                .padding(.leading)
                        } else {
                            ForEach(recentActivities.prefix(5)) { activity in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("\(activity.assetTag) (\(activity.collection))")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    if let checkIn = activity.checkIn {
                                        Text("Checked in: \(checkIn, formatter: dateFormatter)")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                    if let checkOut = activity.checkOut {
                                        Text("Checked out: \(checkOut, formatter: dateFormatter)")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(10)
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("Dashboard")
            .onAppear {
                fetchTotalAssets()  // Fetch total assets
                fetchRecentActivity()  // Fetch recent activity
            }
        }
    }

    // Fetch the total assets from each collection
    private func fetchTotalAssets() {
        let collections = ["Computer", "Monitor", "Server", "Switches", "iPads"]
        var total = 0
        
        let group = DispatchGroup()  // Use DispatchGroup to manage multiple Firestore requests
        
        for collection in collections {
            group.enter()
            db.collection(collection).getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching \(collection): \(error.localizedDescription)")
                    self.errorMessage = "Error fetching \(collection): \(error.localizedDescription)"
                } else if let documents = snapshot?.documents {
                    let count = documents.count
                    total += count
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.totalAssets = total
            self.isLoading = false
        }
    }

    // Fetch the recent check-in/check-out activities
    private func fetchRecentActivity() {
        let collections = ["Computer", "Monitor", "Server", "Switches", "iPads"]
        var activities: [RecentActivity] = []
        
        let group = DispatchGroup()

        for collection in collections {
            group.enter()
            db.collection(collection).getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching \(collection) recent activity: \(error.localizedDescription)")
                } else if let documents = snapshot?.documents {
                    for document in documents {
                        let data = document.data()
                        let assetTag = document.documentID
                        let checkIn = (data["checkIn"] as? Timestamp)?.dateValue()
                        let checkOut = (data["checkOut"] as? Timestamp)?.dateValue()

                        if let checkIn = checkIn {
                            let activity = RecentActivity(assetTag: assetTag, collection: collection, checkIn: checkIn, checkOut: checkOut)
                            activities.append(activity)
                        } else if let checkOut = checkOut {
                            let activity = RecentActivity(assetTag: assetTag, collection: collection, checkIn: checkIn, checkOut: checkOut)
                            activities.append(activity)
                        }
                    }
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.recentActivities = activities.sorted { ($0.checkIn ?? Date.distantPast) > ($1.checkIn ?? Date.distantPast) }
        }
    }
}

// Data model for recent activity
struct RecentActivity: Identifiable {
    let id = UUID()
    let assetTag: String
    let collection: String
    let checkIn: Date?
    let checkOut: Date?
}

// Date formatter for displaying dates
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    DashboardView()
}
