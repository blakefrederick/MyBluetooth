// ManufacturerDatabase.swift
// Harvested from https://bitbucket.org/bluetooth-SIG/public/raw/5bb081901b19cdcc1c2d24f06dc2b3fb7faa4411/assigned_numbers/company_identifiers/company_identifiers.yaml
// This file provides a static lookup for manufacturer names by company ID.

import Foundation

enum ManufacturerDatabase {
    private static var companies: [UInt16: String] = {
        guard let url = Bundle.main.url(forResource: "ManufacturerDatabase", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: String]
        else {
            return [:]
        }
        var result: [UInt16: String] = [:]
        for (key, value) in dict {
            if let id = UInt16(key, radix: 16) {
                result[id] = value
            }
        }
        return result
    }()

    static func name(for id: UInt16) -> String? {
        return companies[id]
    }
}
