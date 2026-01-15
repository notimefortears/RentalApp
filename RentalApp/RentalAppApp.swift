import SwiftUI
import SwiftData

@main
struct RentalAppNewApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Apartment.self, Guest.self, FamilyMember.self]) // ✅ Added FamilyMember
    }
}
