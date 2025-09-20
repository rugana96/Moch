import SwiftUI
import PhotosUI
import SwiftData

struct PetCardView: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext

    // Local image selection state (in-memory). Persist later in the model if desired.
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.blue.opacity(0.35), .purple.opacity(0.35)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.95))
                        }
                    }
                }
                .frame(width: 96, height: 96)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(.white.opacity(0.7), lineWidth: 2))
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)

                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    Image(systemName: "camera.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(.blue, in: Circle())
                        .overlay(Circle().strokeBorder(.white.opacity(0.7), lineWidth: 1))
                }
                .offset(x: 6, y: 6)
            }

            VStack(alignment: .center, spacing: 6) {
                VStack(spacing: 2) {
                    Text(pet.name)
                        .font(.headline)
                    Text(pet.birthday, style: .date)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if let typeName = pet.type.displayName {
                    HStack(spacing: 8) {
                        Image(systemName: pet.type.systemImageName)
                        Text(typeName)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 0)
            .padding(.bottom, 8)
            .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        )
        .onAppear {
            self.imageData = pet.imageData
        }
        .task(id: selectedItem) {
            await loadImageData()
        }
        .animation(.snappy, value: imageData)
    }

    private func loadImageData() async {
        guard let selectedItem else { return }
        do {
            if let data = try await selectedItem.loadTransferable(type: Data.self) {
                await MainActor.run {
                    self.imageData = data
                    pet.imageData = data
                    try? modelContext.save()
                }
            }
        } catch {
            // Handle errors silently for now
            print("Failed to load image data: \(error)")
        }
    }
}

// Helpers for PetType display; provide safe fallbacks if not defined in the project
private extension PetType {
    var displayName: String? {
        switch self {
        case .dog: return "Dog"
        case .cat: return "Cat"
        default: return String(describing: self)
        }
    }

    var systemImageName: String {
        switch self {
        case .dog: return "pawprint.fill"
        case .cat: return "pawprint"
        default: return "pawprint"
        }
    }
}

#Preview {
    // NOTE: Replace with a real Pet instance if needed
    let sample = Pet(name: "Mochi", birthday: .now, type: .dog)
    PetCardView(pet: sample)
        .padding()
}
