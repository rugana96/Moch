import SwiftUI
import SwiftData

struct ReminderRow: View {
    @Bindable var reminder: Reminder

    private var petName: String? {
        reminder.pet?.name
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: reminder.type.symbolName)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.headline)
                HStack(spacing: 6) {
                    Text(reminder.scheduledDate, style: .date)
                    Text(reminder.scheduledDate, style: .time)
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                if let petName {
                    Label(petName, systemImage: "pawprint")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let notes = reminder.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            if reminder.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let reminder = Reminder(title: "Vet Visit",
                            scheduledDate: .now,
                            type: .vetVisit,
                            notes: "Bring vaccination record")
    ReminderRow(reminder: reminder)
        .padding()
        .previewLayout(.sizeThatFits)
}
