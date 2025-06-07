import SwiftUI
import CoreBluetooth

struct DeviceRow: View {
    var device: CBPeripheral
    var rssi: NSNumber
    @EnvironmentObject var btManager: BluetoothManager

    var body: some View {
        VStack(alignment: .leading) {
            Text(btManager.readableName(device.name, adv: btManager.discoveredAdvData[device]))
                .font(.headline)
                .foregroundColor(.white)
            Text("RSSI: \(rssi), Est. Distance: \(btManager.estimateDistance(fromRSSI: rssi))")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(5)
        .background(Color.blue)
        .cornerRadius(8)
    }
}
