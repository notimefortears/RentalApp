import SwiftData
import Foundation

@Model
class FamilyMember {
    var id = UUID()
    var fullName: String
    var email: String
    var phoneNumber: String
    var relationship: String // "Spouse", "Child", "Parent", etc.
    var passportImageData: Data?
    
    @Relationship(deleteRule: .nullify) var primaryGuest: Guest?
    
    init(fullName: String, email: String = "", phoneNumber: String = "",
         relationship: String = "Family", passportImageData: Data? = nil,
         primaryGuest: Guest? = nil) {
        self.fullName = fullName
        self.email = email
        self.phoneNumber = phoneNumber
        self.relationship = relationship
        self.passportImageData = passportImageData
        self.primaryGuest = primaryGuest
    }
    
    var hasPassport: Bool {
        passportImageData != nil
    }
}
