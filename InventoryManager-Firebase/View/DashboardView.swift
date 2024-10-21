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
    @State private var recentActivities: [RecentActivity] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var searchText: String = ""
    @State private var filteredActivities: [RecentActivity] = []
    @State private var keyboardOffset: CGFloat = 0

    let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                LinearGradient(gradient: Gradient(colors: [Color(.systemGray6), Color(.systemBackground)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 20) {
                        // Total Assets Section - Now wider and more prominent
                        VStack(alignment: .center, spacing: 8) {
                            HStack {
                                Image(systemName: "cube.box.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                    .padding(.leading, 10)
                                
                                VStack(alignment: .leading) {
                                    Text("Total Assets")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.white)

                                    if let errorMessage = errorMessage {
                                        Text("Error: \(errorMessage)")
                                            .foregroundColor(.red)
                                            .padding()
                                    } else if isLoading {
                                        ProgressView("Loading data...")
                                            .padding()
                                    } else {
                                        Text("\(totalAssets)")
                                            .font(.system(size: 60, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [.purple, .blue]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing))
                            )
                            .shadow(radius: 8)
                            .padding(.horizontal)
                        }

                        // Search Bar Section
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                TextField("Search Asset Tag", text: $searchText)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            .padding()
                            .background(Color(.systemGray5).opacity(0.3))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .onChange(of: searchText) { _ in
                                filterActivities()
                            }
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
                                    NavigationLink(destination: AssetDetailView(activity: activity)) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                VStack(alignment: .leading) {
                                                    Text("\(activity.assetTag)")
                                                        .font(.headline)
                                                        .bold()
                                                        .foregroundColor(.primary)
                                                    Text("(\(activity.collection))")
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)
                                                }
                                                Spacer()
                                                VStack {
                                                    if let checkIn = activity.checkIn {
                                                        Label("Checked in", systemImage: "arrow.down.circle")
                                                            .font(.caption)
                                                            .foregroundColor(.green)
                                                        Text("\(checkIn, formatter: dateFormatter)")
                                                            .font(.caption)
                                                    }
                                                    if let checkOut = activity.checkOut {
                                                        Label("Checked out", systemImage: "arrow.up.circle")
                                                            .font(.caption)
                                                            .foregroundColor(.red)
                                                        Text("\(checkOut, formatter: dateFormatter)")
                                                            .font(.caption)
                                                    }
                                                }
                                            }
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.systemGray5).opacity(0.6))
                                                .shadow(radius: 3, y: 2)
                                        )
                                        .padding(.horizontal)
                                    }
                                    .transition(.opacity.combined(with: .slide))
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.6))
                        .cornerRadius(15)
                        .shadow(radius: 5, y: 2)
                        .padding(.horizontal)
                    }
                    .padding(.top)
                }
                .navigationTitle("Dashboard")
                .onAppear {
                    fetchTotalAssets()
                    fetchRecentActivity()
                }
            }
        }
    }

    private func fetchTotalAssets() {
        let collections = ["Computer", "Monitor", "Server", "Switches", "iPads"]
        var total = 0
        
        let group = DispatchGroup()
        
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
    // Method to dismiss the keyboard
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        withAnimation {
            keyboardOffset = 0
        }
    }
    // Method to observe the keyboard and adjust view accordingly
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
            self.keyboardOffset = keyboardFrame.height - 150  // Adjust as needed
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            self.keyboardOffset = 0
        }
    }


    private func fetchRecentActivity() {
        let collections = ["Computer", "Monitor", "Server", "Switches", "iPads"]
        var activities: [RecentActivity] = []
        
        let group = DispatchGroup()

        for collection in collections {
            group.enter()
            
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
            self.recentActivities = activities.sorted {
                let date1 = max($0.checkIn ?? Date.distantPast, $0.checkOut ?? Date.distantPast)
                let date2 = max($1.checkIn ?? Date.distantPast, $1.checkOut ?? Date.distantPast)
                return date1 > date2
            }
            self.filteredActivities = self.recentActivities
        }
    }

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



#Preview {
    DashboardView()
}
