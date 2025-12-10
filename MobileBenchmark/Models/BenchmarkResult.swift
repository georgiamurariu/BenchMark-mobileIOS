//
//  BenchmarkResult.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import Foundation

struct BenchmarkResult: Codable, Identifiable {
    let id: UUID
    let singleThreadedCPUScore: Double
    let multiThreadedCPUScore: Double
    let cpuScore: Double
    let gpuScore: Double
    let ramScore: Double
    let storageScore: Double
    let globalScore: Double
    let timestamp: Date
    let deviceInfo: DeviceInfo
    
    init(id: UUID = UUID(), singleThreadedCPUScore: Double, multiThreadedCPUScore: Double, cpuScore: Double, gpuScore: Double, ramScore: Double, storageScore: Double, globalScore: Double, timestamp: Date, deviceInfo: DeviceInfo) {
        self.id = id
        self.singleThreadedCPUScore = singleThreadedCPUScore
        self.multiThreadedCPUScore = multiThreadedCPUScore
        self.cpuScore = cpuScore
        self.gpuScore = gpuScore
        self.ramScore = ramScore
        self.storageScore = storageScore
        self.globalScore = globalScore
        self.timestamp = timestamp
        self.deviceInfo = deviceInfo
    }
}
