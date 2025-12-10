//
//  SingleThreadedBenchmarkViewModel.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import Foundation
import Observation

@Observable
final class SingleThreadedBenchmarkViewModel {
    var isRunning = false
    var progress: Double = 0
    var primeScore: Double?
    var sortScore: Double?
    var matrixScore: Double?
    var totalScore: Double?
    var lastRunDate: Date?
    
    var primeChartData: [BenchmarkDataPoint] = []
    var sortChartData: [BenchmarkDataPoint] = []
    var matrixChartData: [BenchmarkDataPoint] = []
    
    private let primeBenchmark = PrimeBenchmark()
    private let sortBenchmark = SortBenchmark()
    private let matrixBenchmark = MatrixBenchmark()
    
    func runBenchmark() async {
        isRunning = true
        progress = 0
        primeScore = nil
        sortScore = nil
        matrixScore = nil
        totalScore = nil
        primeChartData = []
        sortChartData = []
        matrixChartData = []
        
        // Run Prime benchmark
        let primeResult = await primeBenchmark.runWithData { p in
            DispatchQueue.main.async {
                self.progress = p * 0.33
            }
        }
        primeScore = primeResult.score
        primeChartData = primeResult.dataPoints
        
        // Run Sort benchmark
        let sortResult = await sortBenchmark.runWithData { p in
            DispatchQueue.main.async {
                self.progress = 0.33 + (p * 0.33)
            }
        }
        sortScore = sortResult.score
        sortChartData = sortResult.dataPoints
        
        // Run Matrix benchmark 
        let matrixResult = await matrixBenchmark.runWithData { p in
            DispatchQueue.main.async {
                self.progress = 0.66 + (p * 0.34)
            }
        }
        matrixScore = matrixResult.score
        matrixChartData = matrixResult.dataPoints
        
        totalScore = (primeScore ?? 0) + (sortScore ?? 0) + (matrixScore ?? 0)
        lastRunDate = Date()
        
        isRunning = false
        progress = 1.0
    }
}
