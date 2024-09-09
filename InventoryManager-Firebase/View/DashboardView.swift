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
    @State private var searchText: String = ""  // Search text
    @State private var filteredActivities: [RecentActivity] = []  // Filtered activities based on search

    let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Total Assets Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Assets")
                            .font(.headline)
                            .foregroundColor(.primary)
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
                                    .foregroundColor(.accentColor)  // Accent color for the total assets
                                    .padding()
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .shadow(radius: 5, y: 2)
                    .padding(.horizontal)

                    // Search Bar
                    VStack(alignment: .leading) {
                        TextField("Search Asset Tag", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .onChange(of: searchText, perform: { value in
                                filterActivities()
                            })
                    }
                    
                    // Recent Activity Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Activity")
                            .font(.headline)
                            .padding(.leading)
                            .foregroundColor(.primary)

                        if filteredActivities.isEmpty {
                            Text("No recent activity.")
                                .foregroundColor(.secondary)
                                .padding(.leading)
                        } else {
                            ForEach(filteredActivities.prefix(5)) { activity in
                                NavigationLink(destination: AssetDetailView(activity: activity)) {  // Link to detailed view
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("\(activity.assetTag)")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        HStack {
                                            Text("(\(activity.collection))")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            
                                            Spacer()

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
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray5))
                                            .shadow(radius: 3, y: 2)
                                    )
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .shadow(radius: 5, y: 2)
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

    // Fetch the recent check-in/check-out activities with better handling
    private func fetchRecentActivity() {
        let collections = ["Computer", "Monitor", "Server", "Switches", "iPads"]
        var activities: [RecentActivity] = []
        
        let group = DispatchGroup()

        for collection in collections {
            group.enter()
            
            // Fetch documents with both checkIn and checkOut considered
            db.collection(collection)
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Error fetching \(collection) recent activity: \(error.localizedDescription)")
                    } else if let documents = snapshot?.documents {
                        for document in documents {
                            let data = document.data()
                            let assetTag = document.documentID
                            let checkIn = (data["checkIn"] as? Timestamp)?.dateValue()
                            let checkOut = (data["checkOut"] as? Timestamp)?.dateValue()
                            
                            // Create activity if there's either a checkIn or checkOut
                            if checkIn != nil || checkOut != nil {
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

        group.notify(queue: .main) {
            // Sort by the most recent checkIn or checkOut
            self.recentActivities = activities.sorted {
                let date1 = max($0.checkIn ?? Date.distantPast, $0.checkOut ?? Date.distantPast)
                let date2 = max($1.checkIn ?? Date.distantPast, $1.checkOut ?? Date.distantPast)
                return date1 > date2
            }
            self.filteredActivities = self.recentActivities  // Set initial state for filtered activities
        }
    }

    // Filter the recent activities based on search text
    private func filterActivities() {
        if searchText.isEmpty {
            filteredActivities = recentActivities
        } else {
            filteredActivities = recentActivities.filter { $0.assetTag.lowercased().contains(searchText.lowercased()) }
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

// Asset detail view to show more info about the asset
struct AssetDetailView: View {
    var activity: RecentActivity

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Asset Tag: \(activity.assetTag)")
                .font(.title)
                .padding()

            Text("Collection: \(activity.collection)")
                .font(.headline)
                .padding()

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

            Spacer()
        }
        .navigationTitle("Asset Details")
        .padding()
    }
}

#Preview {
    DashboardView()
}
