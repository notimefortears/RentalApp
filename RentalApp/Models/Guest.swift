import SwiftData
import Foundation

@Model
class Guest {
    var id = UUID()
    var fullName: String
    var email: String
    var phoneNumber: String
    var address: String
    var passportImageData: Data?
    var createdDate: Date = Date()
    var checkInDate: Date
    var checkOutDate: Date
    var notes: String = "" // ✅ FIXED: was 'description'
    var apartment: Apartment?
    
    @Relationship(deleteRule: .cascade, inverse: \FamilyMember.primaryGuest)
    var familyMembers: [FamilyMember] = []
    
    init(fullName: String, email: String, phoneNumber: String, address: String,
         checkInDate: Date, checkOutDate: Date, apartment: Apartment? = nil,
         passportImageData: Data? = nil, notes: String = "") { // ✅ FIXED
        self.fullName = fullName
        self.email = email
        self.phoneNumber = phoneNumber
        self.address = address
        self.checkInDate = checkInDate
        self.checkOutDate = checkOutDate
        self.apartment = apartment
        self.passportImageData = passportImageData
        self.notes = notes // ✅ FIXED
    }
    
    var hasPassport: Bool {
        passportImageData != nil
    }
    
    var numberOfNights: Int {
        Calendar.current.dateComponents([.day], from: checkInDate, to: checkOutDate).day ?? 0
    }
    
    var totalPeople: Int {
        1 + familyMembers.count
    }
}
