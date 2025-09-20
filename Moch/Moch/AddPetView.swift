import SwiftUI
import SwiftData
import PhotosUI

struct AddPetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // Fields
    @State private var name: String = ""
    @State private var type: PetType = .dog
    @State private var birthday: Date = .now

    // Optional photo
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section("Info") {
                    TextField("Name", text: $name)
                    Picker("Type", selection: $type) {
                        ForEach(PetType.allCases, id: \.self) { t in
                            Text(t.rawValue.capitalized).tag(t)
                        }
                    }
                    DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                }

                Section("Photo") {
                    HStack(spacing: 16) {
                        Group {
                            if let imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage).resizable().scaledToFill()
                            } else {
                                ZStack {
                                    Circle().fill(.gray.opacity(0.2))
                                    Image(systemName: "pawprint.fill").foregroundStyle(.secondary)
                                }
                            }
                        }
                        .frame(width: 72, height: 72)
                        .clipShape(Circle())

                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            Label("Choose Photo", systemImage: "camera.fill")
                        }
                    }
                }
            }
            .navigationTitle("Add Pet")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .task(id: selectedItem) { await loadImageData() }
        }
    }

    private func save() {
        let newPet = Pet(name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                         birthday: birthday,
                         type: type,
                         imageData: imageData)
        modelContext.insert(newPet)
        try? modelContext.save()
        dismiss()
    }

    private func loadImageData() async {
        guard let selectedItem else { return }
        do {
            if let data = try await selectedItem.loadTransferable(type: Data.self) {
                await MainActor.run { self.imageData = data }
            }
        } catch {
            print("Failed to load image data: \(error)")
        }
    }
}

#Preview {
    AddPetView()
        .modelContainer(for: Pet.self, inMemory: true)
}
