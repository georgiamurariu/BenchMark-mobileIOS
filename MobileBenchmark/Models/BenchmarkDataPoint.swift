//
//  BenchmarkDataPoint.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import Foundation

struct BenchmarkDataPoint: Identifiable {
    let id = UUID()
    let size: Int
    let timeMs: Double
    
    //transforma size in text scurt
    var sizeLabel: String {
        if size >= 1_000_000 {
            return "\(size / 1_000_000)M"
        } else if size >= 1_000 {
            return "\(size / 1_000)K"
        } else {
            return "\(size)"
        }
    }
}
