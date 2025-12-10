//
//  PrimeBenchmark.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import Foundation

struct PrimeBenchmark: BenchmarkModule {
    let name = "CPU_Primes"
    
 
    private let testSizes = [50_000, 80_000, 120_000, 150_000]
    private let runsPerSize = 3//sa l maresc nr de masuratori

    //dupa ce se apasa run ruleaza cu runwithdata si ia doar score
    func run(progressCallback: @escaping (Double) -> Void) async -> Double {
        let result = await runWithData(progressCallback: progressCallback)
        return result.score
    }
    
    func runWithData(progressCallback: @escaping (Double) -> Void) async -> BenchmarkRunResult {
        let totalTests = testSizes.count * runsPerSize
        var currentTest = 0
        var allScores: [Double] = []
        var dataPoints: [BenchmarkDataPoint] = []
        
        for maxNumber in testSizes {
            var scoresForSize: [Double] = []
            var timesForSize: [Double] = []
            
            //calculeaza cat dureaza sa se calculeze nr prime pana la un max, trans timp in score
            for _ in 0..<runsPerSize
            {
                let ms = measureTimeMs
                {
                    _ = calculatePrimes(upTo: maxNumber)
                }
                
                let score = normalizeScore(timeMs: ms, baselineMs: 1000.0)
                scoresForSize.append(score)
                timesForSize.append(ms)
                // creste progresul si l trimite la UI
                currentTest += 1
                await MainActor.run {
                    progressCallback(Double(currentTest) / Double(totalTests))
                }
            }
            
            
            allScores.append(geometricMean(scoresForSize))
            
       
            let avgTime = timesForSize.reduce(0, +) / Double(timesForSize.count)
            dataPoints.append(BenchmarkDataPoint(size: maxNumber, timeMs: avgTime))
        }
        
        return BenchmarkRunResult(
            score: geometricMean(allScores),
            dataPoints: dataPoints
        )
    }
    
    private func calculatePrimes(upTo n: Int) -> [Int] {
        var primes: [Int] = []
        primes.reserveCapacity(n / 10)
        
        for i in 2...n {
            if isPrime(i) {
                primes.append(i)
            }
        }
        return primes
    }
    
    private func isPrime(_ num: Int) -> Bool {
        if num < 2 { return false }
        if num == 2 { return true }
        if num % 2 == 0 { return false }
        
        let sqrtNum = Int(Double(num).squareRoot())
        for divisor in stride(from: 3, through: sqrtNum, by: 2) {
            if num % divisor == 0 {
                return false
            }
        }
        return true
    }
}
