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

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
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
        case -60...0: return "Near (~1–2m)"
        case -70..<(-60): return "Moderate (~2–5m)"
        default: return "Far (>5m)"
        }
    }

    func readableName(_ rawName: String?, adv: [String: Any]? = nil) -> String {
        if let adv = adv {
            if let manufacturer = adv[CBAdvertisementDataManufacturerDataKey] as? Data {
                // Try to decode Apple, Samsung, etc. by manufacturer code
                let bytes = [UInt8](manufacturer)
                if bytes.count >= 2 {
                    let code = UInt16(bytes[1]) << 8 | UInt16(bytes[0])
                    switch code {
                    case 0x004C: return "Apple Device"
                    case 0x0075: return "Samsung Device"
                    case 0x00E0: return "Google Device"
                    default: break
                    }
                }
            }
            if let localName = adv[CBAdvertisementDataLocalNameKey] as? String, !localName.isEmpty {
                return localName
            }
        }
        guard let raw = rawName, !raw.isEmpty else { return "Unknown Device" }
        if raw.lowercased().contains("airtag") { return "Apple AirTag" }
        return raw
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
