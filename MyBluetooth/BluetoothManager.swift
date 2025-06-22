import CoreBluetooth
import Foundation

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var discoveredDevices: [CBPeripheral: NSNumber] = [:]
    @Published var discoveredAdvData: [CBPeripheral: [String: Any]] = [:]
    @Published var savedDevices: [SavedDevice] = []

    private var centralManager: CBCentralManager!
    private let userDefaults = UserDefaults.standard
    private let savedDevicesKey = "SavedBluetoothDevices"

    override init() {
        super.init()
        loadSavedDevices()
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
            
            // Update last seen date for saved devices
            if let index = self.savedDevices.firstIndex(where: { $0.id == peripheral.identifier.uuidString }) {
                self.savedDevices[index].updateLastSeen()
                self.savePersistentData()
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
        var companyId: UInt16? = nil
        if
            let adv = adv,
            let mfgData = adv[CBAdvertisementDataManufacturerDataKey] as? Data,
            mfgData.count >= 2
        {
            let bytes = [UInt8](mfgData)
            companyId = UInt16(bytes[1]) << 8 | UInt16(bytes[0])
            manufacturer = ManufacturerDatabase.name(for: companyId!)
            print("DEBUG: Manufacturer ID (LE): 0x\(String(format: "%04X", companyId!)), Name: \(manufacturer ?? "nil")")
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


    
    func addDevice(_ peripheral: CBPeripheral) {
        let deviceName = readableName(peripheral.name, adv: discoveredAdvData[peripheral])
        let newDevice = SavedDevice(id: peripheral.identifier.uuidString, name: deviceName)
        
        // Check if device is already saved
        if !savedDevices.contains(where: { $0.id == peripheral.identifier.uuidString }) {
            savedDevices.append(newDevice)
            savePersistentData()
        }
    }
    
    func removeDevice(_ deviceId: String) {
        savedDevices.removeAll { $0.id == deviceId }
        savePersistentData()
    }
    
    func isDeviceSaved(_ peripheral: CBPeripheral) -> Bool {
        return savedDevices.contains { $0.id == peripheral.identifier.uuidString }
    }
    
    func currentlyDiscoveredDevice(for savedDevice: SavedDevice) -> (CBPeripheral, NSNumber)? {
        for (peripheral, rssi) in discoveredDevices {
            if peripheral.identifier.uuidString == savedDevice.id {
                return (peripheral, rssi)
            }
        }
        return nil
    }
    
    private func loadSavedDevices() {
        if let data = userDefaults.data(forKey: savedDevicesKey),
           let devices = try? JSONDecoder().decode([SavedDevice].self, from: data) {
            savedDevices = devices
        }
    }
    
    private func savePersistentData() {
        if let data = try? JSONEncoder().encode(savedDevices) {
            userDefaults.set(data, forKey: savedDevicesKey)
        }
    }
}
