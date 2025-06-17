import CoreBluetooth
import SwiftUI

struct DeviceDetailView: View {
    let device: CBPeripheral
    let advertisementData: [String: Any]?
    let rssi: NSNumber

    var body: some View {
        List {
            Section(header: Text("Device Info")) {
                Text("Name: \(device.name ?? "Unknown")")
                Text("Identifier: \(device.identifier.uuidString)")
                Text("RSSI: \(rssi)")
                Text("State: \(device.state.description)")

                // Show the raw advertisementData
                if let adv = advertisementData {
                    ForEach(adv.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        if let data = value as? Data {
                            let hexString = data.map { String(format: "%02X", $0) }.joined(separator: " ")
                            Text("[DEBUG] \(key): [\(hexString)]")

                            // If this is the Manufacturer field, decode LE company-ID and show full little-e hex
                            if key == CBAdvertisementDataManufacturerDataKey {
                                let bytes = [UInt8](data)
                                if bytes.count >= 2 {
                                    let companyIdLE = UInt16(bytes[0]) | UInt16(bytes[1]) << 8
                                    let leHexString = bytes.map { String(format: "%02X", $0) }.joined()
                                    Text("  • Company ID (LE): 0x\(String(format: "%04X", companyIdLE))")
                                    Text("  • Full Little-E: \(leHexString)")
                                }
                            }
                        } else {
                            Text("[DEBUG] \(key): \(String(describing: value)) (type: \(type(of: value)))")
                        }
                    }
                }
            }
        }
        .navigationTitle(device.name ?? "Device Details")
    }
}

private extension CBPeripheralState {
    var description: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        case .disconnecting: return "Disconnecting"
        @unknown default: return "Unknown"
        }
    }
}
