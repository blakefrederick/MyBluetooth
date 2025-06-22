import CoreBluetooth
import SwiftUI

struct ScannerView: View {
    @EnvironmentObject var btManager: BluetoothManager
    @State private var sortedDevices: [(CBPeripheral, NSNumber)] = []
    @State private var lastUpdate: Date = .init()

    let updateInterval: TimeInterval = 10

    func updateSortedDevices() {
        let all = btManager.discoveredDevices.map { ($0.key, $0.value) }
        sortedDevices = all.sorted { $0.1.intValue > $1.1.intValue }
        lastUpdate = Date()
    }

    var body: some View {
        NavigationView {
            List {
                // My Devices

                if !btManager.savedDevices.isEmpty {
                    let myFiltered = sortedDevices.filter { peripheral, _ in
                        return btManager.isDeviceSaved(peripheral)
                    }

                    if !myFiltered.isEmpty {
                        Section(header: HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("My Devices Nearby")
                        }) {
                            ForEach(myFiltered, id: \.0.identifier) { peripheral, rssi in
                                NavigationLink(
                                    destination: DeviceDetailView(
                                        device: peripheral,
                                        advertisementData: btManager.discoveredAdvData[peripheral],
                                        rssi: rssi
                                    )
                                ) {
                                    DeviceRow(device: peripheral, rssi: rssi)
                                }
                            }
                        }
                    }
                }

                // Other Devices

                let otherFiltered = sortedDevices.filter { peripheral, _ in
                    return !btManager.isDeviceSaved(peripheral)
                }

                Section(header: Text("Devices Nearby")) {
                    HStack {
                        Text("Devices found: \(otherFiltered.count)")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.vertical, 4)

                    ForEach(otherFiltered, id: \.0.identifier) { peripheral, rssi in
                        NavigationLink(
                            destination: DeviceDetailView(
                                device: peripheral,
                                advertisementData: btManager.discoveredAdvData[peripheral],
                                rssi: rssi
                            )
                        ) {
                            DeviceRow(device: peripheral, rssi: rssi)
                        }
                    }
                }
            }
            .navigationTitle("Bluetooth Scanning")
            .listStyle(InsetGroupedListStyle())
            .background(Color(UIColor.systemIndigo).edgesIgnoringSafeArea(.all))
            .onAppear(perform: updateSortedDevices)
            .onReceive(btManager.$discoveredDevices) { _ in
                if Date().timeIntervalSince(lastUpdate) > updateInterval {
                    updateSortedDevices()
                }
            }
        }
    }
}
