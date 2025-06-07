import CoreBluetooth
import SwiftUI

struct DeviceDetailView: View {
    var device: CBPeripheral
    var rssi: NSNumber
    var advertisementData: [String: Any]?

    var body: some View {
        List {
            Section(header: Text("Device Info")) {
                Text("Name: \(device.name ?? "Unknown")")
                Text("Identifier: \(device.identifier.uuidString)")
                Text("RSSI: \(rssi)")
                Text("State: \(device.state.description)")
            }
            if let adv = advertisementData {
                Section(header: Text("Metadata")) {
                    ForEach(adv.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        Text("\(key): \(String(describing: value))")
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
