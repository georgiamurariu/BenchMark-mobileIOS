//
//  DeviceInfoView.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import SwiftUI

struct DeviceInfoView: View {
    let info: DeviceInfo

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                deviceHeaderSection
                
                VStack(spacing: 12) {
                    DeviceInfoCard(title: "General", rows: [
                        ("Model", info.model),
                        ("iOS Version", info.systemVersion)
                    ])

                    DeviceInfoCard(title: "CPU", rows: [
                        ("Processor", info.cpuName),
                        ("Cores", "\(info.coreCount)")
                    ])

                    DeviceInfoCard(title: "GPU", rows: [
                        ("Graphics", info.gpuName)
                    ])

                    DeviceInfoCard(title: "Memory", rows: [
                        ("Total RAM", formatBytes(info.totalMemory)),
                        ("Available RAM", formatBytes(info.freeMemory))
                    ])

                    DeviceInfoCard(title: "Storage", rows: [
                        ("Total Storage", formatBytes(info.storageTotal)),
                        ("Free Storage", formatBytes(info.storageFree))
                    ])

                    DeviceInfoCard(title: "System Status", rows: [
                        ("Battery Level", "\(Int(info.batteryLevel * 100))%"),
                        ("Thermal State", info.thermalState),
                        ("Low Power Mode", info.lowPowerMode ? "Enabled" : "Disabled")
                    ])
                }
            }
            .padding()
        }
        .navigationTitle("Device Info")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var deviceHeaderSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "iphone")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)
            
            Text(info.model)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("iOS \(info.systemVersion)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        formatter.allowedUnits = [.useGB, .useMB]
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
