//
//  MultithreadedBenchmarkView.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import SwiftUI

struct MultithreadedBenchmarkView: View {
    @State private var viewModel = MultithreadedBenchmarkViewModel()
    
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
        .navigationTitle("Multi-Threaded CPU")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "cpu.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange.gradient)
            
            Text("Multi-Threaded Performance")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tests parallel processing with matrix multiplication, merge sort, and image convolution")
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
                BulletPoint(text: "Parallel Matrix Multiplication")
                BulletPoint(text: "Parallel Merge Sort")
                BulletPoint(text: "Parallel Image Convolution")
            }
            
            Text("All tests utilize all CPU cores")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
            
            Text("Tap 'Start Test' to begin")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var runningSection: some View {
        VStack(spacing: 16) {
            ProgressView(value: viewModel.progress) {
                Text("Running Multi-Threaded Tests...")
                    .font(.headline)
            }
            .tint(.orange)
            
            Text("\(Int(viewModel.progress * 100))%")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.orange)
            
            Text("Testing parallel operations across all CPU cores")
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
                ScoreDisplay(score: score, color: .orange)
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
                    title: "Multi-Threaded Performance - Time vs Input Size",
                    dataPoints: viewModel.chartData,
                    color: .orange
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
                Text("• Tests 4 input sizes for each operation")
                Text("• 3 runs per size for consistency")
                Text("• Parallel matrix: rows distributed across cores")
                Text("• Parallel sort: divide-and-conquer with threads")
                Text("• Image processing: row-based parallelization")
                Text("• Score: (baseline_time / actual_time) × 1000")
                Text("• Final score: geometric mean of all tests")
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
            .background(viewModel.isRunning ? Color.gray : Color.orange)
            .foregroundStyle(.white)
            .cornerRadius(12)
        }
        .disabled(viewModel.isRunning)
    }
}
