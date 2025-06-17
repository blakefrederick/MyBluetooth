# MyBluetooth App: Quick Start

1. Open `MyBluetooth.xcodeproj` in Xcode.
2. Connect your iPhone to your Mac via USB.
3. Select your iPhone as the build target in Xcode.
4. Click the Run ▶️ button to build and install the app on your iPhone.
5. Approve any permissions on your device (Bluetooth).
6. Start scanning for Bluetooth devices.

Apple's built-in Bluetooth menu can show all discoverable devices (including classic Bluetooth and BLE), but iOS apps using CoreBluetooth (like this one) can only see BLE (Bluetooth Low Energy) peripherals that are actively advertising and allowed by Apple's privacy rules.

Many devices (especially classic Bluetooth, audio, HID, or privacy-protected devices) will not appear in third-party apps, even if they show up in the system Bluetooth menu. This is a limitation of iOS for privacy and security.

Despite this, many manufacturers use BLE in addition to classic Bluetooth for features like setup, notifications, and diagnostics. These devices may still appear in this app even if they also support classic Bluetooth or are not visible in the system Bluetooth menu.
