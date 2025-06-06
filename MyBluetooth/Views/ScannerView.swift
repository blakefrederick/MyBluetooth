import SwiftUI

struct ScannerView: View {
    @EnvironmentObject var btManager: BluetoothManager

    var body: some View {
        NavigationView {
            List {
                if !btManager.myDevices.isEmpty {
                    Section(header: Text("My Devices Nearby")) {
                        ForEach(btManager.discoveredDevices.keys.filter { peripheral in
                            btManager.myDevices[peripheral.name ?? ""] != nil
                        }, id: \.identifier) { device in
                            DeviceRow(device: device, rssi: btManager.discoveredDevices[device]!)
                        }
                    }
                }

                Section(header: Text("Other Devices")) {
                    ForEach(btManager.discoveredDevices.keys.filter { peripheral in
                        btManager.myDevices[peripheral.name ?? ""] == nil
                    }, id: \.identifier) { device in
                        DeviceRow(device: device, rssi: btManager.discoveredDevices[device]!)
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
            .navigationTitle("mybluetooth")
            .listStyle(InsetGroupedListStyle())
            .background(Color(UIColor.systemIndigo).edgesIgnoringSafeArea(.all))
        }
    }
}
