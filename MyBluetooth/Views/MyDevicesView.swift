import CoreBluetooth
import SwiftUI

struct MyDevicesView: View {
    @EnvironmentObject var btManager: BluetoothManager

    var body: some View {
        NavigationView {
            List {
                if btManager.savedDevices.isEmpty {
                    Section {
                        VStack(spacing: 8) {
                            Image(systemName: "star.slash")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No devices saved yet")
                                .foregroundColor(.gray)
                                .font(.headline)
                            Text("Scan for devices and add them to My Devices to track them here")
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                } else {
                    ForEach(btManager.savedDevices) { savedDevice in
                        Section {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(savedDevice.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Spacer()

                                    // Check if device is currently online
                                    if let (_, rssi) = btManager.currentlyDiscoveredDevice(for: savedDevice) {
                                        VStack(alignment: .trailing, spacing: 2) {
                                            HStack(spacing: 4) {
                                                Circle()
                                                    .fill(Color.green)
                                                    .frame(width: 8, height: 8)
                                                Text("Online")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.green)
                                            }
                                            Text(btManager.estimateDistance(fromRSSI: rssi))
                                                .font(.caption2)
                                                .foregroundColor(.green)
                                        }
                                    } else {
                                        VStack(alignment: .trailing, spacing: 2) {
                                            HStack(spacing: 4) {
                                                Circle()
                                                    .fill(Color.gray)
                                                    .frame(width: 8, height: 8)
                                                Text("Offline")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.gray)
                                            }
                                            Text("Not detected")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Added: \(savedDevice.addedDate.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    if let lastSeen = savedDevice.lastSeenDate {
                                        Text("Last seen: \(lastSeen.formatted(date: .abbreviated, time: .shortened))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                HStack {
                                    // Check if device is currently online for details button
                                    if let (currentDevice, rssi) = btManager.currentlyDiscoveredDevice(for: savedDevice) {
                                        NavigationLink(
                                            destination: DeviceDetailView(
                                                device: currentDevice,
                                                advertisementData: btManager.discoveredAdvData[currentDevice],
                                                rssi: rssi
                                            )
                                        ) {
                                            HStack {
                                                Image(systemName: "info.circle")
                                                Text("View Details")
                                            }
                                        }
                                        .foregroundColor(.blue)
                                    }

                                    Spacer()
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("My Devices")
            .listStyle(InsetGroupedListStyle())
            .background(Color(UIColor.systemIndigo).edgesIgnoringSafeArea(.all))
        }
    }
}
