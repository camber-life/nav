//
//  ManageContactsView.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//


import SwiftUI

struct ManageContactsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var contactsManager: ContactsManager
    @State private var showAddContactSheet: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(contactsManager.contacts) { contact in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(contact.fullName)
                                .font(.headline)
                            Text(contact.phoneNumber)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                .onDelete(perform: contactsManager.removeContacts)
            }
            .navigationTitle("Manage Contacts")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddContactSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddContactSheet) {
                AddContactView { newContact in
                    contactsManager.addContact(newContact)
                }
            }
        }
    }
}
