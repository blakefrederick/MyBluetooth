import CoreBluetooth
import Foundation

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
        case -80 ..< -70: return "Far (~5–10m)"
        default: return "Very Far (>10m)"
        }
    }

    func readableName(_ rawName: String?, adv: [String: Any]? = nil) -> String {
        var manufacturer: String? = nil
        if
            let adv = adv,
            let mfgData = adv[CBAdvertisementDataManufacturerDataKey] as? Data,
            mfgData.count >= 2
        {
            let bytes = [UInt8](mfgData)
            let companyId = UInt16(bytes[1]) << 8 | UInt16(bytes[0])
            manufacturer = ManufacturerDatabase.name(for: companyId)
        }

        // Prefer rawName, then manufacturer, then fallback
        if let raw = rawName, !raw.isEmpty {
            if let manu = manufacturer {
                return "\(raw) - \(manu)"
            } else {
                return raw
            }
        }
        if let manu = manufacturer {
            return manu
        }
        // Fallback to advertised localName
        if
            let adv = adv,
            let local = adv[CBAdvertisementDataLocalNameKey] as? String,
            !local.isEmpty
        {
            return local
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
