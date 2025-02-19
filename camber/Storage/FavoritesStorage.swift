//
//  FavoritesStorage.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//


import Foundation

public class FavoritesStorage {
    static let userDefaultsKey = "com.yourapp.userfavorites"
    
    public static func loadFavorites() -> [FavoriteItem] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return [] }
        do {
            let decoded = try JSONDecoder().decode([FavoriteItem].self, from: data)
            return decoded
        } catch {
            print("Failed to decode favorites:", error)
            return []
        }
    }
    
    public static func saveFavorites(_ items: [FavoriteItem]) {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to encode favorites:", error)
        }
    }
}
