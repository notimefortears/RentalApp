# 🏡 RentalApp

RentalApp is an iOS application built with **SwiftUI** and **SwiftData** that helps manage apartment rentals and guest information. It allows you to store apartments, register guests and their family members, and keep important booking notes and documents in one place

---

## ✨ Features

- 📍 Manage **Apartments**
  - Title, address, price per night, details, image, and maximum number of guests
- 👤 Manage **Guests**
  - Full name, email, phone number, relationship
  - Booking notes
  - Passport image storage
- 👨‍👩‍👧 Manage **Family Members**
  - Linked to a primary guest
  - Passport availability tracking
- 🗂 Local persistence using **SwiftData**
- 🎨 Modern UI built with **SwiftUI**
- 🧪 Unit tests and UI tests included

---

## 🛠 Tech Stack

- **Swift 5+**
- **SwiftUI**
- **SwiftData** (Apple’s modern persistence framework)
- **Xcode**
- **iOS 17+** (recommended for SwiftData support)


---

## 🚀 Getting Started

### 1. Clone the repository
```bash
git clone https://github.com/your-username/RentalApp.git

2. Open in Xcode

cd RentalApp
open RentalApp.xcodeproj

3. Run the app

    Select an iPhone simulator (e.g., iPhone 15)

    Press ⌘ + R to build and run

🧩 Data Models

The app uses SwiftData models:

.modelContainer(for: [Apartment.self, Guest.self, FamilyMember.self])

-Apartment

    -title

    -address

    -pricePerNight

    -details

    -imageName

    -maxGuests

-Guest

    -fullName

    -email

    -phoneNumber

    -notes

    -passportImageData

-FamilyMember

    -fullName

    -relationship

    -passportImageData

    -Linked to a Guest
