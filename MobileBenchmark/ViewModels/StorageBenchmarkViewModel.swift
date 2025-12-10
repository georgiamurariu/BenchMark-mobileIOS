//
//  StorageBenchmarkViewModel.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import Foundation
import Observation

@Observable
final class StorageBenchmarkViewModel {
    var isRunning = false
    var progress: Double = 0
    var score: Double?
    var lastRunDate: Date?
    var chartData: [BenchmarkDataPoint] = []
    
    private let benchmark = StorageBenchmark()
    
    func runBenchmark() async {
        isRunning = true
        progress = 0
        score = nil
        chartData = []
        
        let result = await benchmark.runWithData { p in
            DispatchQueue.main.async {
                self.progress = p
            }
        }
        
        score = result.score
        chartData = result.dataPoints
        lastRunDate = Date()
        
        isRunning = false
        progress = 1.0
    }
}
