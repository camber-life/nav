//
//  ContactBar.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//


import SwiftUI

struct ContactBar: View {
    @State private var showContacts: Bool = false
    @EnvironmentObject var contactsManager: ContactsManager
    
    private let expandedWidth = UIScreen.main.bounds.width - 30
    private let expandedHeight: CGFloat = 76
    
    var body: some View {
        if showContacts {
            HStack(spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(contactsManager.contacts) { contact in
                            Button(action: {
                                if let url = URL(string: "tel://\(contact.phoneNumber)"),
                                   UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                VStack {
                                    Circle()
                                        .fill(Color.purple)
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Text(String(contact.firstName.prefix(1)))
                                                .font(.headline)
                                                .foregroundColor(.white)
                                        )
                                    Text(contact.firstName)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
                Spacer(minLength: 8)
                Button(action: {
                    withAnimation { showContacts.toggle() }
                }) {
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
            .padding(.trailing, 12)
            .frame(width: expandedWidth, height: expandedHeight)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(radius: 4)
            .transition(.move(edge: .trailing))
            .offset(x: 10)
        } else {
            Button(action: { withAnimation { showContacts.toggle() } }) {
                Image(systemName: "phone.circle")
                    .offset(x: -15)
                    .font(.title2)
                    .padding(25)
                    .foregroundStyle(Color.white)
                    .background(Color.purple.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 4)
            }
            .offset(x: 200)
        }
    }
}
