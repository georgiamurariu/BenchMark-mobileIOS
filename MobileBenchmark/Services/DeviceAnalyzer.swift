//
//  DeviceAnalyzer.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import Foundation
import UIKit
import Metal

final class DeviceAnalyzer {
    func getDeviceInfo() -> DeviceInfo {
        UIDevice.current.isBatteryMonitoringEnabled = true

        let device = UIDevice.current
        let model = getDeviceModel()
        let systemVersion = device.systemVersion

        let cpuName = getCPUName()
        let coreCount = ProcessInfo.processInfo.processorCount

        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let freeMemory = MemoryInfo.freeMemoryBytes()

        let gpuName = MTLCreateSystemDefaultDevice()?.name ?? "Unknown GPU"

        let storageTotal = StorageInfo.totalDiskSpace()
        let storageFree = StorageInfo.freeDiskSpace()

        let batteryLevel = device.batteryLevel
        let thermalState = getThermalStateString()
        let lowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled

        return DeviceInfo(
            model: model,
            systemVersion: systemVersion,
            cpuName: cpuName,
            coreCount: coreCount,
            totalMemory: totalMemory,
            freeMemory: freeMemory,
            gpuName: gpuName,
            storageTotal: storageTotal,
            storageFree: storageFree,
            batteryLevel: batteryLevel,
            thermalState: thermalState,
            lowPowerMode: lowPowerMode
        )
    }
    
    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        }
        return modelCode ?? UIDevice.current.model
    }
    
    private func getCPUName() -> String {
        let brandString = sysctlString("machdep.cpu.brand_string")
        if !brandString.isEmpty {
            return brandString
        }
        
        let hwModel = sysctlString("hw.model")
        if !hwModel.isEmpty {
            return hwModel
        }
        
        return "Apple Silicon"
    }
    
    private func getThermalStateString() -> String {
        switch ProcessInfo.processInfo.thermalState {
        case .nominal: return "Nominal"
        case .fair: return "Fair"
        case .serious: return "Serious"
        case .critical: return "Critical"
        @unknown default: return "Unknown"
        }
    }

    private func sysctlString(_ name: String) -> String {
        var size: Int = 0
        sysctlbyname(name, nil, &size, nil, 0)
        
        guard size > 0 else { return "" }
        
        var value = [CChar](repeating: 0, count: size)
        sysctlbyname(name, &value, &size, nil, 0)
        
        if value.isEmpty { return "" }
        if value.last != 0 {
            value.append(0)
        }
        
        return String(cString: value)
    }
}

    enum MemoryInfo {

        // memorie folosită de aplicația ta (phys_footprint)
        static func appMemoryFootprintBytes() -> UInt64 {
            var info = task_vm_info_data_t()
            var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.stride) / 4

            let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                    task_info(mach_task_self_,
                              task_flavor_t(TASK_VM_INFO),
                              $0,
                              &count)
                }
            }

            guard kerr == KERN_SUCCESS else { return 0 }
            return UInt64(info.phys_footprint)
        }

        // aproximare memorie liberă = total - footprint app
        static func freeMemoryBytes() -> UInt64 {
            let total = ProcessInfo.processInfo.physicalMemory
            let usedByApp = appMemoryFootprintBytes()
            return total > usedByApp ? total - usedByApp : 0
        }
    }


enum StorageInfo {
    static func totalDiskSpace() -> UInt64 {
        (try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())[.systemSize] as? UInt64) ?? 0
    }

    static func freeDiskSpace() -> UInt64 {
        (try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())[.systemFreeSize] as? UInt64) ?? 0
    }
}
