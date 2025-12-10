//
//  BenchmarkManager.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import Foundation

final class BenchmarkManager {
    private let modules: [BenchmarkModule]

    init(modules: [BenchmarkModule]) {
        self.modules = modules
    }

    func runAll(progress: @escaping (Double) -> Void) async -> [String: Double] {
        var results: [String: Double] = [:]
        let total = Double(modules.count)

        for (i, module) in modules.enumerated() {
            let moduleProgress = Double(i) / total
            
            let score = await module.run { moduleInternalProgress in
                let overallProgress = moduleProgress + (moduleInternalProgress / total)
                progress(overallProgress)
            }
            
            results[module.name] = score
        }
        
        progress(1.0)
        return results
    }
}
