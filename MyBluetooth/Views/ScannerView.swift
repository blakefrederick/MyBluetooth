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
                if !btManager.myDevices.isEmpty {
                    Section(header: Text("My Devices Nearby")) {
                        ForEach(sortedDevices.filter { btManager.myDevices[$0.0.name ?? ""] != nil }, id: \.0.identifier) { device, rssi in
                            NavigationLink(destination: DeviceDetailView(device: device, rssi: rssi, advertisementData: btManager.discoveredAdvData[device])) {
                                DeviceRow(device: device, rssi: rssi)
                            }
                        }
                    }
                }

                Section(header: Text("Devices Nearby")) {
                    HStack {
                        Text("Devices found: \(sortedDevices.filter { btManager.myDevices[$0.0.name ?? ""] == nil }.count)")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    ForEach(sortedDevices.filter { btManager.myDevices[$0.0.name ?? ""] == nil }, id: \.0.identifier) { device, rssi in
                        NavigationLink(destination: DeviceDetailView(device: device, rssi: rssi, advertisementData: btManager.discoveredAdvData[device])) {
                            DeviceRow(device: device, rssi: rssi)
                        }
                        .contextMenu {
                            Button("Add to My Devices") {
                                if let name = device.name {
                                    btManager.addMyDevice(name)
                                }
                            }
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

// Remove the shim, and ensure DeviceDetailView is visible by adding a fileprivate typealias
private typealias _DeviceDetailView = DeviceDetailView
