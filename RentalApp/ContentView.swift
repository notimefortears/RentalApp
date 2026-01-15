import SwiftUI
import SwiftData
import PhotosUI

struct ContentView: View {
    var body: some View {
        TabView {
            BookingCalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Kalender")
                }
            GuestManagerView()
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Gäste")
                }
            ApartmentManagerView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Wohnungen")
                }
        }
    }
}

// MARK: - APARTMENTS (DEUTSCH)
struct ApartmentManagerView: View {
    @Query(sort: \Apartment.title) private var apartments: [Apartment]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddApartment = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(apartments) { apartment in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(apartment.title)
                            .font(.headline)
                        Text(apartment.address)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        HStack {
                            Text("€\(apartment.pricePerNight, specifier: "%.0f")/Nacht")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                            Spacer()
                            Text("Max \(apartment.maxGuests)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.blue.opacity(0.2))
                                .clipShape(Capsule())
                        }
                        Text(apartment.details)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Wohnungen (\(apartments.count))")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddApartment = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddApartment) {
                AddApartmentView()
            }
            .task {
                await seedData()
            }
        }
    }
    
    private func seedData() async {
        let descriptor = FetchDescriptor<Apartment>()
        guard let existing = try? modelContext.fetch(descriptor), existing.isEmpty else { return }
        
        let apartments = [
            Apartment(title: "Gemütliche Loftwohnung", address: "Musterstraße 123", pricePerNight: 150, details: "Moderne Loftwohnung im Stadtzentrum", imageName: "loft", maxGuests: 4),
            Apartment(title: "Strandvilla", address: "Strandweg 456", pricePerNight: 350, details: "Direkter Strandzugang mit Pool", imageName: "villa", maxGuests: 6)
        ]
        
        apartments.forEach { modelContext.insert($0) }
        try? modelContext.save()
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(apartments[index])
        }
        try? modelContext.save()
    }
}

struct AddApartmentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var address = ""
    @State private var pricePerNight = ""
    @State private var details = ""
    @State private var maxGuests = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Wohnungsdaten") {
                    TextField("Titel", text: $title)
                    TextField("Komplette Adresse", text: $address)
                }
                
                Section("Preis & Kapazität") {
                    TextField("Preis pro Nacht (€)", text: $pricePerNight)
                        .keyboardType(.decimalPad)
                    TextField("Max Gäste", text: $maxGuests)
                        .keyboardType(.numberPad)
                }
                
                Section("Beschreibung") {
                    TextField("Details", text: $details, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section {
                    Button("Wohnung speichern") {
                        saveApartment()
                    }
                    .disabled(!formIsValid())
                }
            }
            .navigationTitle("Neue Wohnung")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
        }
    }
    
    private func formIsValid() -> Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !address.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(pricePerNight.trimmingCharacters(in: .whitespaces)) != nil &&
        Int(maxGuests.trimmingCharacters(in: .whitespaces)) != nil
    }
    
    private func saveApartment() {
        guard let price = Double(pricePerNight),
              let guests = Int(maxGuests) else { return }
        
        let apartment = Apartment(
            title: title,
            address: address,
            pricePerNight: price,
            details: details,
            imageName: "house",
            maxGuests: guests
        )
        
        modelContext.insert(apartment)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - FAMILY MEMBER ROW VIEW (DEUTSCH)
struct FamilyMemberRowView: View {
    let familyMember: FamilyMember
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(familyMember.fullName)
                    .font(.headline)
                Spacer()
                Image(systemName: familyMember.hasPassport ? "checkmark.circle.fill" : "xmark.circle")
                    .foregroundStyle(familyMember.hasPassport ? .green : .orange)
                    .font(.caption)
            }
            
            HStack {
                Text(familyMember.relationship)
                    .font(.subheadline)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.orange.opacity(0.2))
                    .clipShape(Capsule())
                Text(familyMember.email.isEmpty ? "Keine E-Mail" : familyMember.email)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if !familyMember.phoneNumber.isEmpty {
                Text(familyMember.phoneNumber)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - FAMILY MEMBER DETAIL VIEW (DEUTSCH)
struct FamilyMemberDetailView: View {
    @Bindable var familyMember: FamilyMember
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Familienmitglied") {
                    Text(familyMember.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(familyMember.relationship)
                        .font(.headline)
                        .foregroundStyle(.orange)
                }
                
                Section("Kontakt") {
                    if !familyMember.email.isEmpty {
                        Text(familyMember.email)
                            .font(.body)
                    }
                    if !familyMember.phoneNumber.isEmpty {
                        Text(familyMember.phoneNumber)
                            .font(.body)
                    }
                }
                
                Section("Pass") {
                    PhotosPicker("Pass aktualisieren", selection: $selectedPhotoItem, matching: .images)
                    
                    if familyMember.hasPassport {
                        Label("Pass hochgeladen", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Text("Kein Pass hochgeladen")
                            .foregroundStyle(.orange)
                    }
                }
            }
            .navigationTitle("Familienmitglied")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schließen") { dismiss() }
                }
            }
            .onChange(of: selectedPhotoItem) { _, _ in
                Task {
                    if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self) {
                        familyMember.passportImageData = data
                        try? modelContext.save()
                    }
                }
            }
        }
    }
}

// MARK: - FIXED GUEST MANAGER (DEUTSCH)
struct GuestManagerView: View {
    @Query(sort: \Guest.createdDate, order: .reverse) private var guests: [Guest]
    @Query(sort: \FamilyMember.fullName) private var familyMembers: [FamilyMember]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedGuest: Guest?
    @State private var selectedFamilyMember: FamilyMember?
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ✅ CUSTOM SEGMENTED CONTROL (DEUTSCH)
                Picker("Tab", selection: $selectedTab) {
                    Text("Hauptgäste").tag(0)
                    Text("Familienmitglieder").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 5)
                
                // ✅ CONTENT BASED ON SELECTION
                if selectedTab == 0 {
                    List(guests) { guest in
                        GuestRowView(guest: guest)
                            .onTapGesture {
                                selectedGuest = guest
                            }
                    }
                } else {
                    List(familyMembers) { familyMember in
                        FamilyMemberRowView(familyMember: familyMember)
                            .onTapGesture {
                                selectedFamilyMember = familyMember
                            }
                    }
                }
            }
            .navigationTitle("Gäste (\(guests.count)) | Familie (\(familyMembers.count))")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddGuestView()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $selectedGuest) { guest in
                GuestDetailView(guest: guest)
            }
            .sheet(item: $selectedFamilyMember) { familyMember in
                FamilyMemberDetailView(familyMember: familyMember)
            }
        }
    }
}

struct GuestRowView: View {
    let guest: Guest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(guest.fullName)
                    .font(.headline)
                Spacer()
                HStack(spacing: 4) {
                    Text("\(guest.totalPeople)")
                        .font(.caption)
                        .fontWeight(.bold)
                    Image(systemName: "person.3.fill")
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.blue.opacity(0.2))
                .clipShape(Capsule())
                Text("\(guest.numberOfNights) Nächte")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green.opacity(0.2))
                    .clipShape(Capsule())
            }
            
            if let apartment = guest.apartment {
                Text(apartment.title)
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
            
            // ✅ COLORED DATES: Green check-in, Red check-out
            HStack(spacing: 4) {
                Text("\(guest.checkInDate, style: .date)")
                    .font(.caption)
                    .foregroundStyle(.green) // ✅ Green for check-in
                    .fontWeight(.medium)
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(guest.checkOutDate, style: .date)")
                    .font(.caption)
                    .foregroundStyle(.red)   // ✅ Red for check-out
                    .fontWeight(.medium)
            }
            .font(.caption)
            
            HStack {
                Image(systemName: guest.hasPassport ? "checkmark.circle.fill" : "xmark.circle")
                    .foregroundStyle(guest.hasPassport ? .green : .orange)
                Text(guest.hasPassport ? "Pass OK" : "Kein Pass")
                    .font(.caption)
                    .foregroundStyle(guest.hasPassport ? .green : .orange)
            }
            
            // SHOW NOTES IF EXISTS
            if !guest.notes.trimmingCharacters(in: .whitespaces).isEmpty {
                Text(guest.notes)
                    .font(.caption)
                    .foregroundStyle(.purple)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.purple.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - GUEST DETAIL WITH EDITABLE NOTES (DEUTSCH)
struct GuestDetailView: View {
    @Bindable var guest: Guest
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var apartments: [Apartment]
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingAddFamilyMember = false
    @State private var isEditingNotes = false
    @FocusState private var isNotesFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Gästedaten") {
                    Text(guest.fullName)
                        .font(.headline)
                    Text(guest.email)
                        .foregroundStyle(.secondary)
                    Text(guest.phoneNumber)
                        .foregroundStyle(.secondary)
                    Text(guest.address)
                        .foregroundStyle(.secondary)
                }
                
                Section("Buchung") {
                    if let apartment = guest.apartment {
                        Label(apartment.title, systemImage: "house.fill")
                            .foregroundStyle(.blue)
                    }
                    Text("\(guest.checkInDate, style: .date) - \(guest.checkOutDate, style: .date)")
                        .foregroundStyle(.secondary)
                    Text("\(guest.numberOfNights) Nächte")
                        .font(.headline)
                        .foregroundStyle(.blue)
                    Text("Gesamt: \(guest.totalPeople) Personen")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                // EDITABLE NOTES
                Section("Notizen") {
                    if isEditingNotes {
                        TextField("Buchungsnotizen...", text: $guest.notes, axis: .vertical)
                            .focused($isNotesFocused)
                            .lineLimit(1...3)
                    } else {
                        if guest.notes.trimmingCharacters(in: .whitespaces).isEmpty {
                            Text("Keine Notizen")
                                .foregroundStyle(.secondary)
                        } else {
                            Text(guest.notes)
                                .foregroundStyle(.purple)
                        }
                    }
                }
                
                Section("Familienmitglieder (\(guest.familyMembers.count))") {
                    if guest.familyMembers.isEmpty {
                        Text("Keine Familienmitglieder")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(guest.familyMembers) { member in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(member.fullName)
                                        .font(.headline)
                                    Text(member.relationship)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: member.hasPassport ? "checkmark.circle.fill" : "xmark.circle")
                                    .foregroundStyle(member.hasPassport ? .green : .orange)
                            }
                        }
                    }
                }
                
                Section("Pass") {
                    PhotosPicker("Pass aktualisieren", selection: $selectedPhotoItem, matching: .images)
                    
                    if guest.hasPassport {
                        Label("Pass hochgeladen", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Text("Kein Pass hochgeladen")
                            .foregroundStyle(.orange)
                    }
                }
                
                Section("Aktionen") {
                    if !isEditingNotes {
                        Button("Notizen bearbeiten") {
                            isEditingNotes = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isNotesFocused = true
                            }
                        }
                        .foregroundStyle(.purple)
                    } else {
                        Button("Fertig") {
                            isEditingNotes = false
                            isNotesFocused = false
                            try? modelContext.save()
                        }
                        .foregroundStyle(.blue)
                    }
                    
                    Button("Familienmitglied hinzufügen") {
                        showingAddFamilyMember = true
                    }
                    .foregroundStyle(.blue)
                    
                    Button("Gast löschen") {
                        modelContext.delete(guest)
                        try? modelContext.save()
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("Gästedetails")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schließen") { dismiss() }
                }
            }
            .sheet(isPresented: $showingAddFamilyMember) {
                AddFamilyMemberView(primaryGuest: guest)
            }
            .onChange(of: selectedPhotoItem) { _, _ in
                Task {
                    if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self) {
                        guest.passportImageData = data
                        try? modelContext.save()
                    }
                }
            }
        }
    }
}

struct AddFamilyMemberView: View {
    @Bindable var primaryGuest: Guest
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var relationship = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var passportData: Data?
    
    let relationships = ["Ehepartner", "Kind", "Elternteil", "Geschwister", "Andere"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Familienmitglied") {
                    TextField("Vollständiger Name", text: $fullName)
                    Picker("Beziehung", selection: $relationship) {
                        ForEach(relationships, id: \.self) { relation in
                            Text(relation).tag(relation)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Kontakt") {
                    TextField("E-Mail (optional)", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    TextField("Telefon (optional)", text: $phone)
                        .keyboardType(.phonePad)
                }
                
                Section("Pass") {
                    PhotosPicker("Pass hochladen", selection: $selectedPhotoItem, matching: .images)
                    
                    if passportData != nil {
                        Label("Pass hochgeladen", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
                
                Section {
                    Button("Familienmitglied hinzufügen") {
                        saveFamilyMember()
                    }
                    .disabled(!formIsValid())
                }
            }
            .navigationTitle("Familienmitglied hinzufügen")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
            .onChange(of: selectedPhotoItem) { _, _ in
                Task {
                    if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self) {
                        passportData = data
                    }
                }
            }
        }
    }
    
    private func formIsValid() -> Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !relationship.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func saveFamilyMember() {
        let familyMember = FamilyMember(
            fullName: fullName,
            email: email,
            phoneNumber: phone,
            relationship: relationship,
            passportImageData: passportData,
            primaryGuest: primaryGuest
        )
        modelContext.insert(familyMember)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - ADD GUEST WITH NOTES (DEUTSCH)
struct AddGuestView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var apartments: [Apartment]
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var notes = ""
    @State private var checkInDate = Date()
    @State private var checkOutDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    @State private var selectedApartment: Apartment?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var passportData: Data?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Gästedaten") {
                    TextField("Vollständiger Name", text: $fullName)
                    TextField("E-Mail", text: $email)
                    TextField("Telefon", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Adresse", text: $address)
                }
                
                Section("Buchung") {
                    DatePicker("Anreise", selection: $checkInDate, displayedComponents: .date)
                    DatePicker("Abreise", selection: $checkOutDate, displayedComponents: .date)
                    
                    Picker("Wohnung", selection: $selectedApartment) {
                        Text("Wohnung wählen").tag(Apartment?.none)
                        ForEach(apartments) { apartment in
                            Text(apartment.title).tag(Optional(apartment))
                        }
                    }
                }
                
                Section("Notizen") {
                    TextField("Buchungsnotizen (optional)", text: $notes, axis: .vertical)
                        .lineLimit(1...3)
                }
                
                Section("Pass") {
                    PhotosPicker("Pass hochladen", selection: $selectedPhotoItem, matching: .images)
                    
                    if passportData != nil {
                        Label("Pass hochgeladen", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
                
                Section {
                    Button("Gast speichern") {
                        saveGuest()
                    }
                    .disabled(!formIsValid())
                }
            }
            .navigationTitle("Neuer Gast")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
            .onChange(of: checkInDate) { _, newValue in
                checkOutDate = Calendar.current.date(byAdding: .day, value: 1, to: newValue)!
            }
            .onChange(of: selectedPhotoItem) { _, _ in
                Task {
                    if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self) {
                        passportData = data
                    }
                }
            }
        }
    }
    
    private func formIsValid() -> Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty && selectedApartment != nil
    }
    
    private func saveGuest() {
        let guest = Guest(
            fullName: fullName,
            email: email,
            phoneNumber: phone,
            address: address,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            apartment: selectedApartment,
            passportImageData: passportData,
            notes: notes
        )
        modelContext.insert(guest)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - CALENDAR VIEWS (DEUTSCH)
// MARK: - CALENDAR VIEWS (DEUTSCH)
struct BookingCalendarView: View {
    @Query private var apartments: [Apartment]
    @Query private var guests: [Guest]
    @State private var selectedApartment: Apartment?
    @State private var currentMonth = Date()
    @State private var selectedGuest: Guest?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                MonthNavigation(currentMonth: $currentMonth)
                
                if apartments.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "house")
                            .font(.system(size: 60))
                            .foregroundStyle(.gray)
                        Text("Keine Wohnungen")
                            .foregroundStyle(.secondary)
                        Text("Fügen Sie Wohnungen im Wohnungen-Tab hinzu")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    
                    Picker("Wohnung", selection: $selectedApartment) {
                        Text("Alle").tag(Apartment?.none)
                        ForEach(apartments) { apt in
                            Text(apt.title).tag(Optional(apt))
                        }
                    }
                    .pickerStyle(.menu)
                    
                    CalendarGrid(
                        days: calendarDays,
                        onGuestTap: { guest in selectedGuest = guest }
                    )
                }
            }
            .navigationTitle("Buchungen")
            .padding()
            .sheet(item: $selectedGuest) { GuestDetailView(guest: $0) }
        }
    }
    
    // MARK: Build calendar days with flags
    private var calendarDays: [CalendarDay] {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: currentMonth)
        let first = cal.date(from: comps)!
        
        var result: [CalendarDay] = []
        
        let weekday = cal.component(.weekday, from: first)
        for _ in 0 ..< weekday-1 { result.append(.empty()) }
        
        let range = cal.range(of: .day, in: .month, for: first)!
        for day in range {
            let date = cal.date(byAdding: .day, value: day-1, to: first)!
            
            if let (guest, isCI, isCO, isStay) = guestForDate(date) {
                result.append(.full(
                    date: date,
                    guest: guest,
                    isCheckIn: isCI,
                    isCheckOut: isCO,
                    isStay: isStay
                ))
            } else {
                result.append(.full(
                    date: date,
                    guest: nil,
                    isCheckIn: false,
                    isCheckOut: false,
                    isStay: false
                ))
            }
        }
        return result
    }
    
    // MARK: Identify check-in/out/stay days
    private func guestForDate(_ date: Date) -> (Guest?, Bool, Bool, Bool)? {
        guard let apt = selectedApartment else { return nil }
        
        let cal = Calendar.current
        let d = cal.startOfDay(for: date)
        
        return guests.first { g in
            g.apartment?.id == apt.id &&
            d >= cal.startOfDay(for: g.checkInDate) &&
            d <= cal.startOfDay(for: g.checkOutDate)
        }
        .map { g in
            let ci = cal.startOfDay(for: g.checkInDate)
            let co = cal.startOfDay(for: g.checkOutDate)
            let isCI = d == ci
            let isCO = d == co
            let isST = d > ci && d < co
            return (g, isCI, isCO, isST)
        }
    }
}

// MARK: MONTH HEADER
struct MonthNavigation: View {
    @Binding var currentMonth: Date
    
    var body: some View {
        HStack {
            Button {
                currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
            } label: { Image(systemName:"chevron.left").font(.title2) }
            
            Spacer()
            
            Text(monthString).font(.title2).bold()
            
            Spacer()
            
            Button {
                currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
            } label: { Image(systemName:"chevron.right").font(.title2) }
        }
        .padding()
        .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var monthString: String {
        let df = DateFormatter()
        df.dateFormat = "MMMM yyyy"
        return df.string(from: currentMonth)
    }
}

// MARK: CalendarDay WITH FLAGS
struct CalendarDay: Identifiable, Hashable {
    let id = UUID()
    let date: Date?
    let guest: Guest?
    let isCheckIn: Bool
    let isCheckOut: Bool
    let isStay: Bool
    
    static func empty() -> CalendarDay {
        .init(date:nil, guest:nil, isCheckIn:false, isCheckOut:false, isStay:false)
    }
    
    static func full(date: Date, guest: Guest?, isCheckIn: Bool, isCheckOut: Bool, isStay: Bool) -> CalendarDay {
        .init(date: date, guest: guest, isCheckIn: isCheckIn, isCheckOut: isCheckOut, isStay: isStay)
    }
}

// MARK: GRID
struct CalendarGrid: View {
    let days: [CalendarDay]
    let onGuestTap: (Guest) -> Void
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7), spacing: 8) {
            
            // Weekday header
            ForEach(["So","Mo","Di","Mi","Do","Fr","Sa"], id:\.self) {
                Text($0).font(.caption).frame(height: 30)
            }
            
            // Days
            ForEach(days) { d in
                DayCell(day: d) { g in onGuestTap(g) }
            }
        }
    }
}

// MARK: DAY CELL (Final working version)
struct DayCell: View {
    let day: CalendarDay
    let onTap: (Guest) -> Void
    
    var body: some View {
        Group {
            if let date = day.date {
                
                let dayNumber = Calendar.current.component(.day, from: date)
                let guest = day.guest
                
                let bg: Color = day.isCheckIn ? .green.opacity(0.85)
                            : day.isCheckOut ? .red.opacity(0.85)
                            : day.isStay ? .blue.opacity(0.85)
                            : .clear
                
                let stroke: Color = day.isCheckIn ? .green
                                 : day.isCheckOut ? .red
                                 : day.isStay ? .clear
                                 : .green
                
                let scale: CGFloat = day.isCheckIn || day.isCheckOut ? 1.25
                                  : day.isStay ? 1.1
                                  : 1.0
                
                let textColor: Color = (day.isCheckIn || day.isCheckOut || day.isStay) ? .white : .primary
                
                Circle()
                    .fill(bg)
                    .overlay(
                        Circle().stroke(stroke, lineWidth: guest == nil ? 2 : 0)
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        VStack(spacing: 1) {
                            
                            Text("\(dayNumber)")
                                .font(.caption)
                                .foregroundColor(textColor)
                            
                            if let g = guest, g.totalPeople > 1 {
                                Text("\(g.totalPeople)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }
                            
                            if day.isCheckIn {
                                Image(systemName:"arrow.down").font(.caption2).foregroundColor(.white)
                            }
                            if day.isCheckOut {
                                Image(systemName:"arrow.up").font(.caption2).foregroundColor(.white)
                            }
                        }
                    )
                    .scaleEffect(scale)
                    .onTapGesture {
                        if let g = guest { onTap(g) }
                    }
                
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
        }
    }
}
#Preview {
    ContentView()
        .modelContainer(for: [Apartment.self, Guest.self, FamilyMember.self])
}
