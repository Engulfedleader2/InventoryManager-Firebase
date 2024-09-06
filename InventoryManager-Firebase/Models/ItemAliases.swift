//
//  ItemAliases.swift
//  InventoryManager-Firebase
//
//  Created by Israel on 9/1/24.
//

import Foundation

class ItemAliases{
    //This is a dioctonary to store hard-coded alises
    private static let aliases: [String: [String]] = [
        "ambir scanner": ["id scanner"],
        "tmagic scanner": ["check scanner", "T-Magic Scanner", "Teller Scanner"]
    ]
    // Method to find the canonical name for a given alias.
    static func canonicalName(for alias: String) -> String? {
        let standardizedAlias = alias.lowercased()

        // Search through the dictionary to find which canonical name matches the alias
        for (canonicalName, aliasList) in aliases {
            if aliasList.contains(standardizedAlias) {
                return canonicalName
            }
        }
        return nil
    }
}
