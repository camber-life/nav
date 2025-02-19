//
//  ContactsManager.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//


import Foundation

class ContactsManager: ObservableObject {
    @Published var contacts: [ContactItem] = []
    
    private let key = "com.yourapp.contacts"
    
    init() {
        loadContacts()
    }
    
    func loadContacts() {
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                let decoded = try JSONDecoder().decode([ContactItem].self, from: data)
                self.contacts = decoded
            } catch {
                print("Error decoding contacts: \(error)")
            }
        }
    }
    
    func saveContacts() {
        do {
            let data = try JSONEncoder().encode(contacts)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Error encoding contacts: \(error)")
        }
    }
    
    func addContact(_ contact: ContactItem) {
        contacts.append(contact)
        saveContacts()
    }
    
    func removeContacts(at offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
        saveContacts()
    }
}