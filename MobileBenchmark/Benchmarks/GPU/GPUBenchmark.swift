//
//  GPUBenchmark.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import Foundation
import Metal
import MetalKit

struct GPUBenchmark: BenchmarkModule {
    let name = "GPU"
    
    private let textureSizes = [512, 1024, 1536, 2048]
    private let runsPerSize = 3

    func run(progressCallback: @escaping (Double) -> Void) async -> Double {
        let result = await runWithData(progressCallback: progressCallback)
        return result.score
    }
    
    func runWithData(progressCallback: @escaping (Double) -> Void) async -> BenchmarkRunResult {
        guard let device = MTLCreateSystemDefaultDevice(),
              let queue = device.makeCommandQueue() else {
            return BenchmarkRunResult(score: 0, dataPoints: [])
        }
        
        let totalTests = textureSizes.count * runsPerSize
        var currentTest = 0
        var allScores: [Double] = []
        var dataPoints: [BenchmarkDataPoint] = []
        
        for size in textureSizes {
            var scoresForSize: [Double] = []
            var timesForSize: [Double] = []
            
            for _ in 0..<runsPerSize {
                let ms = await performGPUOperations(device: device, queue: queue, size: size)
                let score = normalizeScore(timeMs: ms, baselineMs: 100.0)
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
    
    private func performGPUOperations(device: MTLDevice, queue: MTLCommandQueue, size: Int) async -> Double {
        let totalTime = measureTimeMs {
            // Test 1: Texture rendering
            performTextureOperations(device: device, queue: queue, size: size)
            
            // Test 2: Compute shader operations
            performComputeOperations(device: device, queue: queue, size: size)
            
            // Test 3: Buffer operations
            performBufferOperations(device: device, queue: queue)
        }
        
        return totalTime
    }
    
    private func performTextureOperations(device: MTLDevice, queue: MTLCommandQueue, size: Int) {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: size,
            height: size,
            mipmapped: false
        )
        textureDescriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]
        
        guard let texture = device.makeTexture(descriptor: textureDescriptor) else { return }
        
        for _ in 0..<10 {
            guard let commandBuffer = queue.makeCommandBuffer() else { continue }
            
            let renderPassDescriptor = MTLRenderPassDescriptor()
            renderPassDescriptor.colorAttachments[0].texture = texture
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
                red: Double.random(in: 0...1),
                green: Double.random(in: 0...1),
                blue: Double.random(in: 0...1),
                alpha: 1.0
            )
            renderPassDescriptor.colorAttachments[0].storeAction = .store
            
            if let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                encoder.endEncoding()
            }
            
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
        }
    }
    
    private func performComputeOperations(device: MTLDevice, queue: MTLCommandQueue, size: Int) {
        let dataSize = size * size * 4
        
        guard let inputBuffer = device.makeBuffer(length: dataSize, options: .storageModeShared),
              let outputBuffer = device.makeBuffer(length: dataSize, options: .storageModeShared) else {
            return
        }
        
        // Fill input buffer with random data
        let inputPointer = inputBuffer.contents().bindMemory(to: Float.self, capacity: size * size)
        for i in 0..<(size * size) {
            inputPointer[i] = Float.random(in: 0...1)
        }
        
        // Simulate compute operations with buffer copies and transformations
        for _ in 0..<20 {
            guard let commandBuffer = queue.makeCommandBuffer(),
                  let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {
                continue
            }
            
            blitEncoder.copy(
                from: inputBuffer,
                sourceOffset: 0,
                to: outputBuffer,
                destinationOffset: 0,
                size: dataSize
            )
            
            blitEncoder.endEncoding()
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
        }
        
        _ = outputBuffer.contents()
    }
    
    private func performBufferOperations(device: MTLDevice, queue: MTLCommandQueue) {
        let bufferSize = 64 * 1024 * 1024
        
        guard let bufferA = device.makeBuffer(length: bufferSize, options: .storageModeShared),
              let bufferB = device.makeBuffer(length: bufferSize, options: .storageModeShared) else {
            return
        }
        
        for _ in 0..<30 {
            guard let commandBuffer = queue.makeCommandBuffer(),
                  let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {
                continue
            }
            
            blitEncoder.copy(
                from: bufferA,
                sourceOffset: 0,
                to: bufferB,
                destinationOffset: 0,
                size: bufferSize
            )
            
            blitEncoder.endEncoding()
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
        }
    }
}
