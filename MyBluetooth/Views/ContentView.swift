import SwiftUI

struct ContentView: View {
    @EnvironmentObject var btManager: BluetoothManager

    var body: some View {
        TabView {
            ScannerView()
                .tabItem { Label("Scan", systemImage: "dot.radiowaves.left.and.right") }

            MyDevicesView()
                .tabItem { Label("My Devices", systemImage: "star.fill") }
        }
        .accentColor(.white)
    }
}
