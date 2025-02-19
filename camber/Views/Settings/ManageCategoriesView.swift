import SwiftUI

struct ManageCategoriesView: View {
    @State private var categoryGroups: [CategorySettingGroup] = CategorySettingsStorage.load() ?? defaultCategoryGroups
    // A set to keep track of which group IDs are expanded.
    @State private var expandedGroupIDs: Set<String> = []

    var body: some View {
        NavigationView {
            List {
                ForEach($categoryGroups) { $group in
                    // Use a DisclosureGroup for collapsible sections.
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expandedGroupIDs.contains(group.id) },
                            set: { newValue in
                                if newValue {
                                    expandedGroupIDs.insert(group.id)
                                } else {
                                    expandedGroupIDs.remove(group.id)
                                }
                            }
                        ),
                        content: {
                            // List all toggles for categories in the group.
                            ForEach($group.categories) { $cat in
                                Toggle(isOn: $cat.isOn) {
                                    Text(cat.title)
                                }
                            }
                        },
                        label: {
                            // Use our custom header view.
                            CategoryGroupHeaderView(
                                group: $group,
                                enabledCount: group.categories.filter { $0.isOn }.count,
                                totalCount: group.categories.count
                            )
                        }
                    )
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Manage Categories")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        CategorySettingsStorage.save(categoryGroups)
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        // Optionally dismiss or perform other actions.
                    }
                }
            }
        }
    }
}

struct CategoryGroupHeaderView: View {
    @Binding var group: CategorySettingGroup
    let enabledCount: Int
    let totalCount: Int

    var body: some View {
        HStack {
            // The ColorPicker shows the current color (as a circle)
            // and brings up the iOS color picker inline.
            ColorPicker("", selection: $group.groupColor)
                .labelsHidden()
                .frame(width: 24, height: 24)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(group.groupName)
                    .font(.headline)
                Text("\(enabledCount) of \(totalCount) enabled")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
