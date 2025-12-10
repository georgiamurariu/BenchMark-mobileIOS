//
//  RAMBenchmark.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import Foundation

struct RAMBenchmark: BenchmarkModule {
    let name = "RAM"
    
    private let bufferSizes = [32, 64, 96, 128] // MB
    private let runsPerSize = 3

    func run(progressCallback: @escaping (Double) -> Void) async -> Double {
        let result = await runWithData(progressCallback: progressCallback)
        return result.score
    }
    
    func runWithData(progressCallback: @escaping (Double) -> Void) async -> BenchmarkRunResult {
        let totalTests = bufferSizes.count * runsPerSize
        var currentTest = 0
        var allScores: [Double] = []
        var dataPoints: [BenchmarkDataPoint] = []
        
        for sizeMB in bufferSizes {
            var scoresForSize: [Double] = []
            var timesForSize: [Double] = []
            
            for _ in 0..<runsPerSize {
                let ms = performMemoryOperations(sizeMB: sizeMB)
                let score = normalizeScore(timeMs: ms, baselineMs: 1000.0)
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
    
    private func performMemoryOperations(sizeMB: Int) -> Double {
        let size = sizeMB * 1024 * 1024
        let count = size / MemoryLayout<UInt64>.size
        var buffer = [UInt64](repeating: 0, count: count)

        // Sequential write
        let seqWriteMs = measureTimeMs {
            for i in 0..<count {
                buffer[i] = UInt64(i)
            }
        }
        
        // Sequential read
        let seqReadMs = measureTimeMs {
            var sum: UInt64 = 0
            for i in 0..<count {
                sum &+= buffer[i]
            }
            _ = sum
        }

        // Random access
        let randMs = measureTimeMs {
            for _ in 0..<count {
                let idx = Int.random(in: 0..<count)
                buffer[idx] &+= 1
            }
        }

        return seqWriteMs + seqReadMs + randMs
    }
}
