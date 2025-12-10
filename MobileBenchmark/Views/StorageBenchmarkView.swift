//
//  StorageBenchmarkView.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import SwiftUI

struct StorageBenchmarkView: View {
    @State private var viewModel = StorageBenchmarkViewModel()
    
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
        .navigationTitle("Storage Benchmark")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "internaldrive")
                .font(.system(size: 60))
                .foregroundStyle(.orange.gradient)
            
            Text("Storage Performance Test")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tests disk I/O speed with read and write operations")
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
                BulletPoint(text: "Sequential Write Speed")
                BulletPoint(text: "Sequential Read Speed")
                BulletPoint(text: "Overall I/O Performance")
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
                Text("Running Storage Benchmark...")
                    .font(.headline)
            }
            .tint(.orange)
            
            Text("\(Int(viewModel.progress * 100))%")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.orange)
            
            Text("Testing read, write, and random access performance")
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
                    title: "Storage Performance - Time vs File Size (MB)",
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
                Text("• Tests 4 file sizes: 40MB to 100MB")
                Text("• 3 runs per size for accuracy")
                Text("• Sequential write operations")
                Text("• Sequential read operations")
                Text("• Random seek and read tests")
                Text("• Score: (baseline_time / actual_time) × 1000")
                Text("• Combined using geometric mean")
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
