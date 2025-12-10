//
//  RAMBenchmarkView.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import SwiftUI

struct RAMBenchmarkView: View {
    @State private var viewModel = RAMBenchmarkViewModel()
    
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
        .navigationTitle("RAM Benchmark")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "memorychip")
                .font(.system(size: 60))
                .foregroundStyle(.green.gradient)
            
            Text("Memory Performance Test")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tests memory speed with sequential and random access patterns")
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
                BulletPoint(text: "Sequential Read/Write Speed")
                BulletPoint(text: "Random Access Performance")
                BulletPoint(text: "Memory Bandwidth")
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
                Text("Running RAM Benchmark...")
                    .font(.headline)
            }
            .tint(.green)
            
            Text("\(Int(viewModel.progress * 100))%")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.green)
            
            Text("Testing sequential and random memory access patterns")
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
                ScoreDisplay(score: score, color: .green)
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
                    title: "RAM Performance - Time vs Buffer Size (MB)",
                    dataPoints: viewModel.chartData,
                    color: .green
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
                Text("• Tests 4 buffer sizes: 32MB to 128MB")
                Text("• 3 runs per size to ensure consistency")
                Text("• Sequential write and read operations")
                Text("• Random access pattern testing")
                Text("• Score: (baseline_time / actual_time) × 1000")
                Text("• Final score uses geometric mean")
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
            .background(viewModel.isRunning ? Color.gray : Color.green)
            .foregroundStyle(.white)
            .cornerRadius(12)
        }
        .disabled(viewModel.isRunning)
    }
}
