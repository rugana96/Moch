import Foundation
import SwiftData

enum ReminderType: String, Codable, CaseIterable, Identifiable, Sendable {
    case vetVisit
    case vaccine
    case medication
    case grooming
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .vetVisit: return "Vet Visit"
        case .vaccine: return "Vaccine"
        case .medication: return "Medication"
        case .grooming: return "Grooming"
        case .other: return "Other"
        }
    }

    var symbolName: String {
        switch self {
        case .vetVisit: return "stethoscope"
        case .vaccine: return "syringe"
        case .medication: return "pills"
        case .grooming: return "scissors"
        case .other: return "bell"
        }
    }
}

@Model
final class Reminder {
    var title: String
    var scheduledDate: Date
    var notes: String?
    var type: ReminderType
    var isCompleted: Bool
    var createdAt: Date
    var pet: Pet?

    init(title: String,
         scheduledDate: Date,
         type: ReminderType,
         notes: String? = nil,
         isCompleted: Bool = false,
         pet: Pet? = nil,
         createdAt: Date = .now) {
        self.title = title
        self.scheduledDate = scheduledDate
        self.type = type
        self.notes = notes
        self.isCompleted = isCompleted
        self.pet = pet
        self.createdAt = createdAt
    }
}
