//
//  CategoryBar.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//


import SwiftUI
import MapKit

struct CategoryBar: View {
    @Binding var showCategories: Bool
    @Binding var allowedCategories: [MKPointOfInterestCategory]
    @Binding var categorySettings: [CategorySettingGroup]
    
    private let expandedWidth = UIScreen.main.bounds.width - 30
    private let expandedHeight: CGFloat = 76
    
    var activeCategories: [CategoryItem] {
        var items: [CategoryItem] = []
        for group in categorySettings {
            for cat in group.categories {
                if cat.isOn {
                    let poiCategory = MKPointOfInterestCategory(rawValue: cat.id)
                    let icon = defaultCategoryIcons[cat.id] ?? "questionmark.circle"
                    items.append(CategoryItem(category: poiCategory, title: cat.title, iconName: icon))
                }
            }
        }
        return items
    }
    
    var body: some View {
        if showCategories {
            HStack(spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(activeCategories, id: \.title) { cat in
                            CategoryButton(categoryItem: cat, groupColor: groupColor(for: cat), allowedCategories: $allowedCategories)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                Spacer(minLength: 8)
                Button(action: { withAnimation { showCategories = false } }) {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(15)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(radius: 4)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .frame(width: expandedWidth, height: expandedHeight)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(radius: 4)
            .transition(.move(edge: .trailing))
            .offset(x: 10)
        } else {
            Button(action: { withAnimation { showCategories = true } }) {
                Image(systemName: "circle.hexagongrid.circle")
                    .offset(x: -15)
                    .font(.title2)
                    .padding(25)
                    .foregroundStyle(Color.white)
                    .background(Color.blue.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 4)
            }
            .offset(x: 200)
        }
    }
    
    func groupColor(for categoryItem: CategoryItem) -> Color {
        for group in categorySettings {
            if group.categories.contains(where: { $0.id == categoryItem.category.rawValue && $0.isOn }) {
                return group.groupColor
            }
        }
        return .gray
    }
}

struct CategoryButton: View {
    let categoryItem: CategoryItem
    let groupColor: Color
    @Binding var allowedCategories: [MKPointOfInterestCategory]
    
    var body: some View {
        Button(action: {
            if isAllowed() {
                allowedCategories.removeAll { $0 == categoryItem.category }
            } else {
                allowedCategories.append(categoryItem.category)
            }
        }) {
            VStack(spacing: 4) {
                Circle()
                    .fill(isAllowed() ? groupColor : groupColor.opacity(0.5))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: categoryItem.iconName)
                            .font(.headline)
                            .foregroundColor(.white)
                    )
                Text(categoryItem.title)
                    .font(.caption2)
                    .foregroundColor(.primary)
            }
        }
    }
    
    func isAllowed() -> Bool {
        allowedCategories.contains(categoryItem.category)
    }
}
