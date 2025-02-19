////
////  CategoryGroupHeaderView.swift
////  camber
////
////  Created by Roddy Gonzalez on 2/15/25.
////
//
//import SwiftUI
//
//// MARK: - CategoryGroupHeaderView
//struct CategoryGroupHeaderView: View {
//    @Binding var group: CategorySettingGroup
//    @State private var showColorPicker = false
//    
//    var body: some View {
//        HStack {
//            Button {
//                showColorPicker.toggle()
//            } label: {
//                Circle()
//                    .fill(group.groupColor)
//                    .frame(width: 24, height: 24)
//            }
//            .popover(isPresented: $showColorPicker) {
//                ColorPicker("Pick a color", selection: $group.groupColor)
//                    .padding()
//            }
//            Text(group.groupName)
//                .font(.headline)
//        }
//    }
//}
