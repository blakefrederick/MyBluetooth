import SwiftUI

struct MyDevicesView: View {
    @EnvironmentObject var btManager: BluetoothManager

    var body: some View {
        NavigationView {
            List {
                ForEach(Array(btManager.myDevices.keys), id: \.self) { name in
                    Section(header: Text(name)) {
                        ForEach(btManager.myDevices[name] ?? [], id: \.self) { timestamp in
                            Text("Seen at: \(timestamp.formatted())")
                        }
                        Button("Remove") {
                            btManager.removeMyDevice(name)
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("My Devices")
            .listStyle(InsetGroupedListStyle())
            .background(Color(UIColor.systemIndigo).edgesIgnoringSafeArea(.all))
        }
    }
}
