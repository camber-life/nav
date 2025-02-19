//
//  AddContactView.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//


import SwiftUI

struct AddContactView: View {
    @Environment(\.dismiss) var dismiss
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phoneNumber: String = ""
    
    // Validate: only allow exactly 10 digits (ignoring non-digit characters)
    var isPhoneValid: Bool {
        let digits = phoneNumber.filter { "0123456789".contains($0) }
        return digits.count == 10
    }
    
    // Format phone number for display (optional formatting)
    func formatPhone(_ number: String) -> String {
        let digits = number.filter { "0123456789".contains($0) }
        guard digits.count == 10 else { return number }
        let area = digits.prefix(3)
        let middle = digits.dropFirst(3).prefix(3)
        let last = digits.dropFirst(6)
        return "(\(area)) \(middle)-\(last)"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact Info")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
            }
            .navigationTitle("Add Contact")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let digits = phoneNumber.filter { "0123456789".contains($0) }
                        let newContact = ContactItem(firstName: firstName,
                                                     lastName: lastName,
                                                     phoneNumber: digits)
                        onSave(newContact)
                        dismiss()
                    }
                    .disabled(!isPhoneValid)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    var onSave: (ContactItem) -> Void
}
