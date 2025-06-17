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
        case -80 ..< -70: return "Far (~5–10m)"
        default: return "Very Far (>10m)"
        }
    }

    func readableName(_ rawName: String?, adv: [String: Any]? = nil) -> String {
        let knownManufacturers: [UInt16: String] = [
            0x004C: "Apple, Inc.",
            0x0075: "Samsung Electronics Co. Ltd.",
            0x00E0: "Google",
            0x4B24: "Tile, Inc.",
            0x7658: "Fitbit, Inc.",
            0x3CB8: "Nintendo Co., Ltd.",
            0xF0CC: "Sony Interactive Entertainment",
            0x0131: "Microsoft",
            0x0006: "Microsoft",
            0x000F: "Broadcom Corporation",
            0x000D: "Texas Instruments Inc.",
            0x000A: "Nordic Semiconductor ASA",
            0x0009: "Motorola",
            0x000C: "CSR plc (Qualcomm)",
            0x0001: "Ericsson Technology Licensing",
            0x0002: "Nokia Mobile Phones",
            0x0003: "Intel Corp.",
            0x0004: "IBM Corp.",
            0x0005: "Toshiba Corp.",
            0x0007: "3Com",
            0x0008: "Lucent Technologies",
            0x0010: "AVM Berlin",
            0x0011: "BandSpeed, Inc.",
            0x0012: "Mansella Ltd.",
            0x0013: "NEC Corporation",
            0x0014: "WavePlus Technology Co., Ltd.",
            0x0015: "Alcatel",
            0x0016: "Philips Semiconductors",
            0x0017: "C Technologies AB",
            0x0018: "Open Interface North America",
            0x0019: "R F Micro Devices",
            0x001A: "Hitachi Ltd.",
            0x001B: "Symbol Technologies, Inc.",
            0x001C: "Tenovis",
            0x001D: "Macronix International Co. Ltd.",
            0x001E: "GCT Semiconductor",
            0x001F: "Norwood Systems",
            0x0020: "MewTel Technology Inc.",
            0x0021: "ST Microelectronics",
            0x0022: "Synopsys, Inc.",
            0x0023: "Red-M (Communications) Ltd",
            0x0024: "Commil Ltd",
            0x0025: "Computer Access Technology Corporation (CATC)",
            0x0026: "Eclipse (HQ Espana) S.L.",
            0x0027: "Renesas Electronics Corporation",
            0x0028: "Mobilian Corporation",
            0x0029: "Terax",
            0x002A: "Integrated System Solution Corp.",
            0x002B: "Matsushita Electric Industrial Co., Ltd.",
            0x002C: "Gennum Corporation",
            0x002D: "Research In Motion",
            0x002E: "Ivy Wireless",
            0x002F: "Siemens AG",
            0x0030: "Microsoft Corp.",
            0x0031: "Taixingbang Technology (HK) Co., Ltd.",
            0x0032: "Apt Ltd.",
            0x0033: "TeraLogic, Inc.",
            0x0034: "Tenovis GmbH & Co. KG",
            0x0035: "Qualcomm Technologies International, Ltd. (QTIL)",
            0x0036: "Inventel",
            0x0037: "AVM Audiovisuelles Marketing und Computersysteme GmbH",
            0x0038: "Alcatel",
            0x0039: "Philips Semiconductors",
            0x003A: "C Technologies AB",
            0x003B: "Open Interface North America",
            0x003C: "R F Micro Devices",
            0x003D: "Hitachi Ltd.",
            0x003E: "Symbol Technologies, Inc.",
            0x003F: "Tenovis",
            // etc etc etc etc etc etc prob put this elsewhere
        ]

        var manufacturer: String? = nil
        if
            let adv = adv,
            let mfgData = adv[CBAdvertisementDataManufacturerDataKey] as? Data,
            mfgData.count >= 2
        {
            let bytes = [UInt8](mfgData)
            let companyId = UInt16(bytes[1]) << 8 | UInt16(bytes[0])
            if let manu = knownManufacturers[companyId] {
                manufacturer = manu
            }
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
