//
//  BenchmarkModule..swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import Foundation
//schelet teste
struct BenchmarkRunResult {
    let score: Double
    let dataPoints: [BenchmarkDataPoint]
}

protocol BenchmarkModule {
    var name: String { get }
    func run(progressCallback: @escaping (Double) -> Void) async -> Double
    func runWithData(progressCallback: @escaping (Double) -> Void) async -> BenchmarkRunResult
}
//dif e in nanosecunde si impartim sa avem in milisecunde
func measureTimeMs(_ block: () -> Void) -> Double {
    let start = DispatchTime.now().uptimeNanoseconds
    block()
    let end = DispatchTime.now().uptimeNanoseconds
    return Double(end - start) / 1_000_000.0
}

//fac media geometrica a testelor si fac radacina de ordin n=nr de valori
func geometricMean(_ values: [Double]) -> Double {
    guard !values.isEmpty else { return 0 }
    let product = values.reduce(1.0, *)
    return pow(product, 1.0 / Double(values.count))
}
//transform timp in score; baseline= timp de referinta
func normalizeScore(timeMs: Double, baselineMs: Double) -> Double {
    return (baselineMs / timeMs) * 1000.0
}
