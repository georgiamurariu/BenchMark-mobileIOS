//
//  DashboardViewModel.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import Foundation
import Observation

@Observable
final class DashboardViewModel {
    var deviceInfo: DeviceInfo?
    var isRunning = false
    var progress: Double = 0
    var lastResult: BenchmarkResult?

    private let analyzer = DeviceAnalyzer()
    private let processor = ResultProcessor()
    private let reporter = ReportGenerator()
    private let manager: BenchmarkManager

    init() {
        self.manager = BenchmarkManager(modules: [
            PrimeBenchmark(),
            SortBenchmark(),
            MatrixBenchmark(),
            MultithreadedBenchmark(),
            GPUBenchmark(),
            RAMBenchmark(),
            StorageBenchmark()
        ])
        self.deviceInfo = analyzer.getDeviceInfo()
    }

    func refreshDeviceInfo() {
        deviceInfo = analyzer.getDeviceInfo()
    }

    func startBenchmarks() async {
        isRunning = true
        progress = 0

        let results = await manager.runAll { p in
            DispatchQueue.main.async {
                self.progress = p
            }
        }

        let cpu = (results["CPU_Primes"] ?? 0)
                + (results["CPU_Sort"] ?? 0)
                + (results["CPU_Matrix"] ?? 0)
        let multiThreaded = results["CPU_Multithreaded"] ?? 0
        let totalCPU = cpu + multiThreaded
        let gpu = results["GPU"] ?? 0
        let ram = results["RAM"] ?? 0
        let storage = results["Storage"] ?? 0

        let global = processor.globalScore(cpu: totalCPU, gpu: gpu, ram: ram, storage: storage)
        let info = deviceInfo ?? analyzer.getDeviceInfo()

        let benchResult = BenchmarkResult(
            singleThreadedCPUScore: cpu,
            multiThreadedCPUScore: multiThreaded,
            cpuScore: totalCPU,
            gpuScore: gpu,
            ramScore: ram,
            storageScore: storage,
            globalScore: global,
            timestamp: Date(),
            deviceInfo: info
        )

        lastResult = benchResult
        isRunning = false
        progress = 1.0

        _ = reporter.save(result: benchResult)
    }
}
