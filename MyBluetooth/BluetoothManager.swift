import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var discoveredDevices: [CBPeripheral: NSNumber] = [:]
    @Published var discoveredAdvData: [CBPeripheral: [String: Any]] = [:]
    @Published var myDevices: [String: [Date]] = [:] // name: [timestamps]

    private var centralManager: CBCentralManager!

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        } else {
            DispatchQueue.main.async {
                self.discoveredDevices.removeAll()
            }
        }
    }

    func centralManager(_: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        DispatchQueue.main.async {
            self.discoveredDevices[peripheral] = RSSI
            self.discoveredAdvData[peripheral] = advertisementData
            if let name = peripheral.name, self.myDevices[name] != nil {
                self.myDevices[name]?.append(Date())
            }
        }
    }

    func estimateDistance(fromRSSI rssi: NSNumber) -> String {
        let rssiValue = rssi.doubleValue
        switch rssiValue {
        case -60 ... 0: return "Near (~1–2m)"
        case -70 ..< -60: return "Moderate (~2–5m)"
        default: return "Far (>5m)"
        }
    }

    func readableName(_ rawName: String?, adv: [String: Any]? = nil) -> String {
        // Try to identify by advertisement data first
        if let adv = adv {
            if let manufacturer = adv[CBAdvertisementDataManufacturerDataKey] as? Data {
                let bytes = [UInt8](manufacturer)
                if bytes.count >= 2 {
                    let code = UInt16(bytes[1]) << 8 | UInt16(bytes[0])
                    switch code {
                    case 0x004C: // Apple
                        // AirTag: Apple uses 0x12 0x19 as the next two bytes (3rd and 4th)
                        if bytes.count >= 4 {
                            if bytes[2] == 0x12 && bytes[3] == 0x19 {
                                return "Apple AirTag"
                            }
                            // Apple Watch (0x07 0x19), iPad (0x0C 0x19), MacBook (0x10 0x19), iPhone (0x02 0x19)
                            if bytes[2] == 0x07 && bytes[3] == 0x19 {
                                return "Apple Watch"
                            }
                            if bytes[2] == 0x0C && bytes[3] == 0x19 {
                                return "iPad"
                            }
                            if bytes[2] == 0x10 && bytes[3] == 0x19 {
                                return "MacBook"
                            }
                            if bytes[2] == 0x02 && bytes[3] == 0x19 {
                                return "iPhone"
                            }
                        }
                        // iPhone/MacBook: Try to use local name or fallback
                        if let localName = adv[CBAdvertisementDataLocalNameKey] as? String, !localName.isEmpty {
                            let lower = localName.lowercased()
                            if lower.contains("iphone") {
                                return "\(localName) (iPhone)"
                            } else if lower.contains("macbook") {
                                return "\(localName) (MacBook)"
                            } else if lower.contains("ipad") {
                                return "\(localName) (iPad)"
                            } else if lower.contains("watch") {
                                return "\(localName) (Apple Watch)"
                            } else if lower.contains("airtag") {
                                return "\(localName) (AirTag)"
                            }
                        }
                        // Fallback for Apple device
                        return "Apple Device"
                    case 0x0075: return "Samsung Device"
                    case 0x00E0: return "Google Device"
                    default: break
                    }
                }
            }
            if let localName = adv[CBAdvertisementDataLocalNameKey] as? String, !localName.isEmpty {
                let lower = localName.lowercased()
                if lower.contains("airtag") { return "\(localName) (AirTag)" }
                if lower.contains("iphone") { return "\(localName) (iPhone)" }
                if lower.contains("macbook") { return "\(localName) (MacBook)" }
                if lower.contains("ipad") { return "\(localName) (iPad)" }
                if lower.contains("watch") { return "\(localName) (Apple Watch)" }
                return localName
            }
        }
        // Try to identify by rawName
        if let raw = rawName, !raw.isEmpty {
            let lower = raw.lowercased()
            if lower.contains("airtag") { return "\(raw) (AirTag)" }
            if lower.contains("iphone") { return "\(raw) (iPhone)" }
            if lower.contains("macbook") { return "\(raw) (MacBook)" }
            if lower.contains("ipad") { return "\(raw) (iPad)" }
            if lower.contains("watch") { return "\(raw) (Apple Watch)" }
            return raw
        }
        return "Unknown Device"
    }

    func addMyDevice(_ name: String) {
        if myDevices[name] == nil {
            myDevices[name] = []
        }
    }

    func removeMyDevice(_ name: String) {
        myDevices.removeValue(forKey: name)
    }
}
