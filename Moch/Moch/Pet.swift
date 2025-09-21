//
//  Item.swift
//  Moch
//
//  Created by Ruben Gago(personal) on 20/9/25.
//

import Foundation
import SwiftData

// A simple SwiftData model for storing pets
// Includes name, birthday, and a limited type (cat or dog)

enum PetType: String, Codable, CaseIterable, Sendable {
    case cat
    case dog
}

@Model
final class Pet {
    // Stored properties
    var name: String
    var birthday: Date
    var type: PetType
    @Attribute(.externalStorage) var imageData: Data?

    init(name: String, birthday: Date, type: PetType, imageData: Data? = nil) {
        self.name = name
        self.birthday = birthday
        self.type = type
        self.imageData = imageData
    }
}

extension PetType {
    var displayName: String {
        switch self {
        case .dog: return "Dog"
        case .cat: return "Cat"
        }
    }

    var systemImageName: String {
        switch self {
        case .dog: return "pawprint.fill"
        case .cat: return "pawprint"
        }
    }
}
