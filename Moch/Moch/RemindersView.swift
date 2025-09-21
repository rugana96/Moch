import SwiftUI
import SwiftData

struct RemindersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Reminder.scheduledDate, order: .forward) private var reminders: [Reminder]
    @State private var showingAddReminder = false

    private var upcomingReminders: [Reminder] {
        reminders.filter { !$0.isCompleted }
    }

    private var completedReminders: [Reminder] {
        reminders.filter { $0.isCompleted }
    }

    var body: some View {
        NavigationStack {
            Group {
                if reminders.isEmpty {
                    ContentUnavailableView("No Reminders",
                                            systemImage: "bell",
                                            description: Text("Track vet visits, vaccines, and medications."))
                        .padding()
                } else {
                    List {
                        if !upcomingReminders.isEmpty {
                            Section("Upcoming") {
                                ForEach(upcomingReminders) { reminder in
                                    ReminderRow(reminder: reminder)
                                        .swipeActions(edge: .trailing) {
                                            Button {
                                                toggleCompletion(for: reminder)
                                            } label: {
                                                Label("Done", systemImage: "checkmark")
                                            }
                                            .tint(.green)

                                            Button(role: .destructive) {
                                                delete(reminder)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                                .onDelete { deleteReminders(at: $0, in: upcomingReminders) }
                            }
                        }

                        if !completedReminders.isEmpty {
                            Section("Completed") {
                                ForEach(completedReminders) { reminder in
                                    ReminderRow(reminder: reminder)
                                        .opacity(0.5)
                                        .swipeActions {
                                            Button(role: .destructive) {
                                                delete(reminder)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }

                                            Button {
                                                toggleCompletion(for: reminder)
                                            } label: {
                                                Label("Reopen", systemImage: "arrow.uturn.left")
                                            }
                                            .tint(.blue)
                                        }
                                }
                                .onDelete { deleteReminders(at: $0, in: completedReminders) }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Reminders")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !reminders.isEmpty {
                        EditButton()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddReminder = true
                    } label: {
                        Label("Add Reminder", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                AddReminderView()
            }
        }
    }

    private func toggleCompletion(for reminder: Reminder) {
        reminder.isCompleted.toggle()
        try? modelContext.save()
    }

    private func delete(_ reminder: Reminder) {
        modelContext.delete(reminder)
        try? modelContext.save()
    }

    private func deleteReminders(at offsets: IndexSet, in source: [Reminder]) {
        withAnimation {
            for index in offsets {
                delete(source[index])
            }
        }
    }
}
