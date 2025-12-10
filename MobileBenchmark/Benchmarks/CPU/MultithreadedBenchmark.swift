//
//  MultithreadedBenchmark.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import Foundation

struct MultithreadedBenchmark: BenchmarkModule {
    let name = "CPU_Multithreaded"
    
    private let matrixSizes = [128, 160, 192, 224]
    private let runsPerSize = 3
    
    func run(progressCallback: @escaping (Double) -> Void) async -> Double {
        let result = await runWithData(progressCallback: progressCallback)
        return result.score
    }
    
    func runWithData(progressCallback: @escaping (Double) -> Void) async -> BenchmarkRunResult {
        let totalTests = matrixSizes.count * runsPerSize * 3 // 3 sub-tests
        var currentTest = 0
        
        var matrixScores: [Double] = []
        var sortScores: [Double] = []
        var imageScores: [Double] = []
        var dataPoints: [BenchmarkDataPoint] = []
        
        for size in matrixSizes {
            var matrixScoresForSize: [Double] = []
            var sortScoresForSize: [Double] = []
            var imageScoresForSize: [Double] = []
            var totalTimesForSize: [Double] = []
            
            for _ in 0..<runsPerSize {
                var runTotalTime = 0.0
                
                // Matrix Multiplication
                let matrixMs = parallelMatrixMultiply(size: size)
                matrixScoresForSize.append(normalizeScore(timeMs: matrixMs, baselineMs: 1000.0))
                runTotalTime += matrixMs
                currentTest += 1
                await MainActor.run {
                    progressCallback(Double(currentTest) / Double(totalTests))
                }
                
                // Parallel Sort
                let sortSize = size * 1000
                let sortMs = parallelMergeSort(size: sortSize)
                sortScoresForSize.append(normalizeScore(timeMs: sortMs, baselineMs: 500.0))
                runTotalTime += sortMs
                currentTest += 1
                await MainActor.run {
                    progressCallback(Double(currentTest) / Double(totalTests))
                }
                
                // Image Processing
                let imageMs = parallelImageProcessing(size: size * 4)
                imageScoresForSize.append(normalizeScore(timeMs: imageMs, baselineMs: 800.0))
                runTotalTime += imageMs
                currentTest += 1
                await MainActor.run {
                    progressCallback(Double(currentTest) / Double(totalTests))
                }
                
                totalTimesForSize.append(runTotalTime)
            }
            
            matrixScores.append(geometricMean(matrixScoresForSize))
            sortScores.append(geometricMean(sortScoresForSize))
            imageScores.append(geometricMean(imageScoresForSize))
            
            let avgTime = totalTimesForSize.reduce(0, +) / Double(totalTimesForSize.count)
            dataPoints.append(BenchmarkDataPoint(size: size, timeMs: avgTime))
        }
        
        let avgMatrixScore = geometricMean(matrixScores)
        let avgSortScore = geometricMean(sortScores)
        let avgImageScore = geometricMean(imageScores)
        
        return BenchmarkRunResult(
            score: geometricMean([avgMatrixScore, avgSortScore, avgImageScore]),
            dataPoints: dataPoints
        )
    }
    
    // MARK: - Parallel Matrix Multiplication
    
    private func parallelMatrixMultiply(size n: Int) -> Double {
        let numThreads = ProcessInfo.processInfo.processorCount
        var matrixA = Array(repeating: Array(repeating: 0.0, count: n), count: n)
        var matrixB = Array(repeating: Array(repeating: 0.0, count: n), count: n)
        var matrixC = Array(repeating: Array(repeating: 0.0, count: n), count: n)
        
    
        for i in 0..<n {
            for j in 0..<n {
                matrixA[i][j] = Double.random(in: 0...1)
                matrixB[i][j] = Double.random(in: 0...1)
            }
        }
        
        let ms = measureTimeMs {
            let rowsPerThread = n / numThreads
            
            DispatchQueue.concurrentPerform(iterations: numThreads) { threadIdx in
                let startRow = threadIdx * rowsPerThread
                let endRow = (threadIdx == numThreads - 1) ? n : startRow + rowsPerThread
                
                for i in startRow..<endRow {
                    multiplyRowByMatrix(A: matrixA, B: matrixB, C: &matrixC, row: i, cols: n)
                }
            }
        }
        
        _ = matrixC[0][0]
        return ms
    }
    
    private func multiplyRowByMatrix(A: [[Double]], B: [[Double]], C: inout [[Double]], row: Int, cols: Int) {
        for j in 0..<cols {
            var sum = 0.0
            for k in 0..<cols {
                sum += A[row][k] * B[k][j]
            }
            C[row][j] = sum
        }
    }
    
    // MARK: - Parallel Merge Sort
    
    private func parallelMergeSort(size: Int) -> Double {
        var array = (0..<size).map { _ in Int.random(in: 0...1_000_000) }
        let maxDepth = Int(log2(Double(ProcessInfo.processInfo.processorCount)))
        
        let ms = measureTimeMs {
            parallelMergeSortRecursive(arr: &array, left: 0, right: size - 1, depth: maxDepth)
        }
        
        _ = array[0]
        return ms
    }
    
    private func parallelMergeSortRecursive(arr: inout [Int], left: Int, right: Int, depth: Int) {
        guard left < right else { return }
        
        if depth <= 0 {
            // Sequential merge sort for small depth
            mergeSortSequential(arr: &arr, left: left, right: right)
        } else {
            let mid = left + (right - left) / 2
            
            DispatchQueue.concurrentPerform(iterations: 2) { index in
                if index == 0 {
                    var leftPart = Array(arr[left...mid])
                    mergeSortSequential(arr: &leftPart, left: 0, right: leftPart.count - 1)
                    for i in 0..<leftPart.count {
                        arr[left + i] = leftPart[i]
                    }
                } else {
                    var rightPart = Array(arr[(mid + 1)...right])
                    mergeSortSequential(arr: &rightPart, left: 0, right: rightPart.count - 1)
                    for i in 0..<rightPart.count {
                        arr[mid + 1 + i] = rightPart[i]
                    }
                }
            }
            
            merge(arr: &arr, left: left, mid: mid, right: right)
        }
    }
    
    private func mergeSortSequential(arr: inout [Int], left: Int, right: Int) {
        guard left < right else { return }
        
        let mid = left + (right - left) / 2
        mergeSortSequential(arr: &arr, left: left, right: mid)
        mergeSortSequential(arr: &arr, left: mid + 1, right: right)
        merge(arr: &arr, left: left, mid: mid, right: right)
    }
    
    private func merge(arr: inout [Int], left: Int, mid: Int, right: Int) {
        let leftPart = Array(arr[left...mid])
        let rightPart = Array(arr[(mid + 1)...right])
        
        var i = 0, j = 0, k = left
        
        while i < leftPart.count && j < rightPart.count {
            if leftPart[i] <= rightPart[j] {
                arr[k] = leftPart[i]
                i += 1
            } else {
                arr[k] = rightPart[j]
                j += 1
            }
            k += 1
        }
        
        while i < leftPart.count {
            arr[k] = leftPart[i]
            i += 1
            k += 1
        }
        
        while j < rightPart.count {
            arr[k] = rightPart[j]
            j += 1
            k += 1
        }
    }
    
    // MARK: - Parallel Image Processing (Convolution)
    
    private func parallelImageProcessing(size: Int) -> Double {
        let numThreads = ProcessInfo.processInfo.processorCount
        let numRows = size
        let numCols = size
        
        // Create input image with random values
        var inputImage = Array(repeating: Array(repeating: 0.0, count: numCols), count: numRows)
        var outputImage = Array(repeating: Array(repeating: 0.0, count: numCols), count: numRows)
        
        for i in 0..<numRows {
            for j in 0..<numCols {
                inputImage[i][j] = Double.random(in: 0...255)
            }
        }
        
        // 3x3 Gaussian blur kernel
        let kernel: [[Double]] = [
            [1/16.0, 2/16.0, 1/16.0],
            [2/16.0, 4/16.0, 2/16.0],
            [1/16.0, 2/16.0, 1/16.0]
        ]
        
        let ms = measureTimeMs {
            let rowsPerThread = numRows / numThreads
            
            DispatchQueue.concurrentPerform(iterations: numThreads) { threadIdx in
                let startRow = threadIdx * rowsPerThread
                let endRow = (threadIdx == numThreads - 1) ? numRows : startRow + rowsPerThread
                
                applyKernel(
                    input: inputImage,
                    output: &outputImage,
                    kernel: kernel,
                    startRow: max(1, startRow),
                    endRow: min(numRows - 1, endRow),
                    numRows: numRows,
                    numCols: numCols
                )
            }
        }
        
        _ = outputImage[0][0]
        return ms
    }
    
    private func applyKernel(
        input: [[Double]],
        output: inout [[Double]],
        kernel: [[Double]],
        startRow: Int,
        endRow: Int,
        numRows: Int,
        numCols: Int
    ) {
        let offset = 1 // For 3x3 kernel
        
        for i in startRow..<endRow {
            for j in 0..<numCols {
                var sum = 0.0
                
                for ki in -offset...offset {
                    for kj in -offset...offset {
                        let ni = i + ki
                        let nj = j + kj
                        
                        if ni >= 0 && ni < numRows && nj >= 0 && nj < numCols {
                            sum += input[ni][nj] * kernel[ki + offset][kj + offset]
                        }
                    }
                }
                
                output[i][j] = sum
            }
        }
    }
}
