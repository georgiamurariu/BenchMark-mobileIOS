//
//  DeviceInfo.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import Foundation

struct DeviceInfo: Codable {
    var model: String
    var systemVersion: String
    var cpuName: String
    var coreCount: Int
    var totalMemory: UInt64
    var freeMemory: UInt64
    var gpuName: String
    var storageTotal: UInt64
    var storageFree: UInt64
    var batteryLevel: Float
    var thermalState: String
    var lowPowerMode: Bool
}
