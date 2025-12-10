//
//  SortBenchmark.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import Foundation

struct SortBenchmark: BenchmarkModule {
    let name = "CPU_Sort"
    
    private let testSizes = [500_000, 1_000_000, 1_500_000, 2_000_000]
    private let runsPerSize = 3

    func run(progressCallback: @escaping (Double) -> Void) async -> Double {
        let result = await runWithData(progressCallback: progressCallback)
        return result.score
    }
    
    func runWithData(progressCallback: @escaping (Double) -> Void) async -> BenchmarkRunResult {
        let totalTests = testSizes.count * runsPerSize
        var currentTest = 0
        var allScores: [Double] = []
        var dataPoints: [BenchmarkDataPoint] = []
        
        for size in testSizes {
            var scoresForSize: [Double] = []
            var timesForSize: [Double] = []
            
            for _ in 0..<runsPerSize {
                var arr = (0..<size).map { _ in Int.random(in: 0...1_000_000) }
                
                let ms = measureTimeMs {
                    arr.sort()
                }
                
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
            dataPoints.append(BenchmarkDataPoint(size: size, timeMs: avgTime))
        }
        
        return BenchmarkRunResult(
            score: geometricMean(allScores),
            dataPoints: dataPoints
        )
    }
}
