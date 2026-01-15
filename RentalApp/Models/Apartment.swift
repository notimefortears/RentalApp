import SwiftData
import Foundation

@Model
class Apartment {
    var id = UUID()
    var title: String
    var address: String
    var pricePerNight: Double
    var details: String
    var imageName: String
    var maxGuests: Int
    
    init(title: String, address: String, pricePerNight: Double, details: String, imageName: String, maxGuests: Int) {
        self.title = title
        self.address = address
        self.pricePerNight = pricePerNight
        self.details = details
        self.imageName = imageName
        self.maxGuests = maxGuests
    }
}
