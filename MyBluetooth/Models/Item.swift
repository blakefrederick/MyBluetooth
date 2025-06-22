import Foundation
import CoreBluetooth

struct SavedDevice: Codable, Identifiable {
    let id: String // UUID string
    let name: String
    let addedDate: Date
    var lastSeenDate: Date?
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
        self.addedDate = Date()
        self.lastSeenDate = nil
    }
    
    mutating func updateLastSeen() {
        self.lastSeenDate = Date()
    }
}
