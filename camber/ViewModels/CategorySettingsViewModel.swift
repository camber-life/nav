//
//  CategorySettingsViewModel.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/18/25.
//


import SwiftUI
import Combine

final class CategorySettingsViewModel: ObservableObject {
    @Published var groups: [CategorySettingGroup] = CategorySettingsStorage.load() ?? defaultCategoryGroups

    func save() {
        CategorySettingsStorage.save(groups)
    }
}