//
//  ContactItem.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/15/25.
//


import Foundation

public struct ContactItem: Identifiable, Codable, Equatable {
    public var id: UUID = UUID()
    public var firstName: String = ""
    public var lastName: String = ""
    public var phoneNumber: String = ""
    
    public var fullName: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }
}
