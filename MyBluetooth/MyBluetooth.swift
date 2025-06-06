import SwiftUI

@main
struct MyBluetooth: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(BluetoothManager())
        }
    }
}
