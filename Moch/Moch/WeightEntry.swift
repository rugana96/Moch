import Foundation
import SwiftData

@Model
final class WeightEntry {
    var weight: Double
    var recordedAt: Date
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    var pet: Pet?
    var petID: UUID

    init(weight: Double,
         recordedAt: Date,
         notes: String? = nil,
         pet: Pet,
         createdAt: Date = .now,
         updatedAt: Date = .now) {
        self.weight = weight
        self.recordedAt = recordedAt
        self.notes = notes
        self.pet = pet
        self.petID = pet.id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension WeightEntry {
    static func notifyChange(for petID: UUID) {
        NotificationCenter.default.post(name: .weightEntriesDidChange,
                                        object: nil,
                                        userInfo: ["petID": petID])
    }
}

extension Notification.Name {
    static let weightEntriesDidChange = Notification.Name("WeightEntriesDidChange")
}
