//
//  MatrixBenchmark.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import Foundation

struct MatrixBenchmark: BenchmarkModule {
    let name = "CPU_Matrix"
    
    private let matrixSizes = [128, 160, 192, 224]
    private let runsPerSize = 3

    func run(progressCallback: @escaping (Double) -> Void) async -> Double {
        let result = await runWithData(progressCallback: progressCallback)
        return result.score
    }
    
    func runWithData(progressCallback: @escaping (Double) -> Void) async -> BenchmarkRunResult {
        let totalTests = matrixSizes.count * runsPerSize
        var currentTest = 0
        var allScores: [Double] = []
        var dataPoints: [BenchmarkDataPoint] = []
        
        for size in matrixSizes {
            var scoresForSize: [Double] = []
            var timesForSize: [Double] = []
            
            for _ in 0..<runsPerSize {
                let ms = performMatrixMultiplication(size: size)
                let score = normalizeScore(timeMs: ms, baselineMs: 2000.0)
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
    
    
    private func performMatrixMultiplication(size n: Int) -> Double {
        var A = Array(repeating: Array(repeating: 0.0, count: n), count: n)
        var B = Array(repeating: Array(repeating: 0.0, count: n), count: n)
        var C = Array(repeating: Array(repeating: 0.0, count: n), count: n)

        for i in 0..<n {
            for j in 0..<n {
                A[i][j] = Double.random(in: 0...1)
                B[i][j] = Double.random(in: 0...1)
            }
        }

        let ms = measureTimeMs {
            DispatchQueue.concurrentPerform(iterations: n) { i in
                for j in 0..<n {
                    var sum = 0.0
                    for k in 0..<n {
                        sum += A[i][k] * B[k][j]
                    }
                    C[i][j] = sum
                }
            }
        }

        _ = C[0][0]
        return ms
    }
}
