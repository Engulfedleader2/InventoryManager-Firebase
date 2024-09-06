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
                    VStack(alignment: .leading) {
                        Text("Total Assets")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.leading)

                        if let errorMessage = errorMessage {
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.red)
                                .padding()
                        } else if isLoading {
                            ProgressView("Loading data...")
                                .padding()
                        } else {
                            Text("\(totalAssets)")  // Display total assets here
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                        }
                    }

                    // Recent Activity Section
                    VStack(alignment: .leading) {
                        Text("Recent Activity")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.leading)

                        if recentActivities.isEmpty {
                            Text("No recent activity.")
                                .foregroundColor(.secondary)
                                .padding(.leading)
                        } else {
                            ForEach(recentActivities.prefix(5)) { activity in  // Show only the 5 most recent activities
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(activity.assetTag) (\(activity.collection))")
                                            .font(.headline)
                                        if let checkIn = activity.checkIn {
                                            Text("Checked in: \(checkIn, formatter: dateFormatter)")
                                                .font(.subheadline)
                                                .foregroundColor(.green)
                                        }
                                        if let checkOut = activity.checkOut {
                                            Text("Checked out: \(checkOut, formatter: dateFormatter)")
                                                .font(.subheadline)
                                                .foregroundColor(.red)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 10)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
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
                    print("\(collection) count: \(count)") // Debugging: Print the count for each collection
                    total += count
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            print("Total Assets: \(total)")  // Debugging: Print the total count
            self.totalAssets = total
            self.isLoading = false
        }
    }

    // Fetch the recent check-in/check-out activities
    private func fetchRecentActivity() {
        let collections = ["Computer", "Monitor", "Server", "Switches", "iPads"]
        var activities: [RecentActivity] = []
        
        let group = DispatchGroup()

        // Loop through each collection to fetch check-in and check-out data
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
                        
                        // Only add the activity if there's a checkIn or checkOut
                        if let checkIn = checkIn, checkIn != Date.distantPast {
                            let activity = RecentActivity(
                                assetTag: assetTag,
                                collection: collection,
                                checkIn: checkIn,
                                checkOut: checkOut
                            )
                            activities.append(activity)
                        } else if let checkOut = checkOut, checkOut != Date.distantPast {
                            let activity = RecentActivity(
                                assetTag: assetTag,
                                collection: collection,
                                checkIn: checkIn,
                                checkOut: checkOut
                            )
                            activities.append(activity)
                        }
                    }
                }
                group.leave()
            }
        }

        // Notify when all async requests complete
        group.notify(queue: .main) {
            // Sort by the most recent activity (check-in or check-out)
            self.recentActivities = activities.sorted {
                let date1 = max($0.checkIn ?? Date.distantPast, $0.checkOut ?? Date.distantPast)
                let date2 = max($1.checkIn ?? Date.distantPast, $1.checkOut ?? Date.distantPast)
                return date1 > date2
            }
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
