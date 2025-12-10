//
//  GPUBenchmarkView.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import SwiftUI

struct GPUBenchmarkView: View {
    @State private var viewModel = GPUBenchmarkViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                
                if !viewModel.isRunning && viewModel.score == nil {
                    instructionsSection
                }
                
                if viewModel.isRunning {
                    runningSection
                } else if let score = viewModel.score {
                    resultsSection(score: score)
                }
                
                actionButton
            }
            .padding()
        }
        .navigationTitle("GPU Benchmark")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "dice.fill")
                .font(.system(size: 60))
                .foregroundStyle(.purple.gradient)
            
            Text("GPU Performance Test")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tests graphics processing unit with Metal buffer operations")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("What this test measures:", systemImage: "info.circle.fill")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                BulletPoint(text: "Metal API Performance")
                BulletPoint(text: "GPU Memory Bandwidth")
                BulletPoint(text: "Graphics Processing Speed")
            }
            
            Text("Tap 'Start Test' to begin")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var runningSection: some View {
        VStack(spacing: 16) {
            ProgressView(value: viewModel.progress) {
                Text("Running GPU Benchmark...")
                    .font(.headline)
            }
            .tint(.purple)
            
            Text("\(Int(viewModel.progress * 100))%")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.purple)
            
            Text("Testing texture rendering, compute operations, and buffer transfers")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func resultsSection(score: Double) -> some View {
        VStack(spacing: 12) {
            Text("Test Results")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 16) {
                ScoreDisplay(score: score, color: .purple)
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .cornerRadius(12)
            
            // Chart Section
            VStack(spacing: 16) {
                Text("Performance Analysis")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                BenchmarkChart(
                    title: "GPU Performance - Time vs Texture Size",
                    dataPoints: viewModel.chartData,
                    color: .purple
                )
            }
            
            scoreExplanationSection
            
            if let date = viewModel.lastRunDate {
                Text("Completed: \(date.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
    }
    
    private var scoreExplanationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("How scores are calculated:", systemImage: "info.circle.fill")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("• Tests 4 texture sizes: 512×512 to 2048×2048")
                Text("• 3 runs per size with texture rendering")
                Text("• Includes compute shader operations")
                Text("• Tests buffer copy performance")
                Text("• Score: (baseline_time / actual_time) × 1000")
                Text("• Results averaged with geometric mean")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
    
    private var actionButton: some View {
        Button {
            Task {
                await viewModel.runBenchmark()
            }
        } label: {
            HStack {
                Image(systemName: viewModel.isRunning ? "hourglass" : "play.circle.fill")
                Text(viewModel.isRunning ? "Running..." : (viewModel.score != nil ? "Run Again" : "Start Test"))
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.isRunning ? Color.gray : Color.purple)
            .foregroundStyle(.white)
            .cornerRadius(12)
        }
        .disabled(viewModel.isRunning)
    }
}

struct ScoreDisplay: View {
    let score: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text("GPU Score")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(String(format: "%.2f", score))
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(color.gradient)
        }
    }
}


