//
//  StorageBenchmark.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import Foundation

struct StorageBenchmark: BenchmarkModule {
    let name = "Storage"
    
    private let fileSizes = [40, 60, 80, 100, 200, 500] // MB
    private let runsPerSize = 3

    func run(progressCallback: @escaping (Double) -> Void) async -> Double {
        let result = await runWithData(progressCallback: progressCallback)
        return result.score
    }
    
    func runWithData(progressCallback: @escaping (Double) -> Void) async -> BenchmarkRunResult {
        let totalTests = fileSizes.count * runsPerSize
        var currentTest = 0
        var allScores: [Double] = []
        var dataPoints: [BenchmarkDataPoint] = []
        
        for sizeMB in fileSizes {
            var scoresForSize: [Double] = []
            var timesForSize: [Double] = []
            
            for runIndex in 0..<runsPerSize {
                let ms = performStorageOperations(sizeMB: sizeMB, runIndex: runIndex)
                let score = normalizeScore(timeMs: ms, baselineMs: 500.0)
                scoresForSize.append(score)
                timesForSize.append(ms)
                
                currentTest += 1
                await MainActor.run {
                    progressCallback(Double(currentTest) / Double(totalTests))
                }
            }
            
            allScores.append(geometricMean(scoresForSize))
            
            let avgTime = timesForSize.reduce(0, +) / Double(timesForSize.count)
            dataPoints.append(BenchmarkDataPoint(size: sizeMB, timeMs: avgTime))
        }
        
        return BenchmarkRunResult(
            score: geometricMean(allScores),
            dataPoints: dataPoints
        )
    }
    
    private func performStorageOperations(sizeMB: Int, runIndex: Int) -> Double {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("bench-\(sizeMB)mb-\(runIndex).dat")
        
        let dataSize = sizeMB * 1024 * 1024
        let data = Data(count: dataSize)

        // Sequential write
        let writeMs = measureTimeMs {
            try? data.write(to: fileURL, options: .atomic)
        }

        // Sequential read
        let readMs = measureTimeMs {
            _ = try? Data(contentsOf: fileURL)
        }
        
        // Random access simulation (multiple small reads)
        let randomReadMs = measureTimeMs {
            if let handle = try? FileHandle(forReadingFrom: fileURL) {
                for _ in 0..<10 {
                    let offset = UInt64.random(in: 0..<UInt64(dataSize - 1024))
                    try? handle.seek(toOffset: offset)
                    _ = try? handle.read(upToCount: 1024)
                }
                try? handle.close()
            }
        }

        try? FileManager.default.removeItem(at: fileURL)

        return writeMs + readMs + randomReadMs
    }
}
