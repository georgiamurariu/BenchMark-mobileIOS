//
//  SingleThreadedBenchmarkView.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import SwiftUI

struct SingleThreadedBenchmarkView: View {
    @State private var viewModel = SingleThreadedBenchmarkViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                
                if !viewModel.isRunning && viewModel.totalScore == nil {
                    instructionsSection
                }
                
                if viewModel.isRunning {
                    runningSection
                } else if viewModel.totalScore != nil {
                    resultsSection
                }
                
                actionButton
            }
            .padding()
        }
        .navigationTitle("Single-Threaded CPU")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "cpu")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)
            
            Text("Single-Threaded Performance")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tests single-core CPU performance with prime numbers, sorting, and matrix operations")
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
                BulletPoint(text: "Prime Number Calculation (single-core)")
                BulletPoint(text: "Array Sorting Performance")
                BulletPoint(text: "Matrix Multiplication")
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
                Text("Running Single-Threaded Tests...")
                    .font(.headline)
            }
            .tint(.blue)
            
            Text("\(Int(viewModel.progress * 100))%")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.blue)
            
            Text("Testing multiple input sizes with 3 runs each")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var resultsSection: some View {
        VStack(spacing: 12) {
            Text("Test Results")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ResultCard(
                    title: "Prime Numbers",
                    score: viewModel.primeScore,
                    icon: "number.circle.fill",
                    color: .blue
                )
                
                ResultCard(
                    title: "Sorting",
                    score: viewModel.sortScore,
                    icon: "arrow.up.arrow.down.circle.fill",
                    color: .green
                )
                
                ResultCard(
                    title: "Matrix Multiplication",
                    score: viewModel.matrixScore,
                    icon: "grid.circle.fill",
                    color: .purple
                )
                
                Divider()
                    .padding(.vertical, 4)
                
                ResultCard(
                    title: "Total Single-Threaded Score",
                    score: viewModel.totalScore,
                    icon: "cpu.fill",
                    color: .blue,
                    isTotal: true
                )
            }
            
            // Charts Section
            VStack(spacing: 16) {
                Text("Performance Analysis")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                
                BenchmarkChart(
                    title: "Prime Numbers - Time vs Input Size",
                    dataPoints: viewModel.primeChartData,
                    color: .blue
                )
                
                BenchmarkChart(
                    title: "Sorting - Time vs Array Size",
                    dataPoints: viewModel.sortChartData,
                    color: .green
                )
                
                BenchmarkChart(
                    title: "Matrix Multiplication - Time vs Matrix Size",
                    dataPoints: viewModel.matrixChartData,
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
                Text("• Each test runs with 4 different input sizes")
                Text("• 3 runs are performed for each size")
                Text("• All tests run on a single CPU core")
                Text("• Scores: (baseline_time / actual_time) × 1000")
                Text("• Geometric mean combines all results")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .padding(.top, 8)
    }
    
    private var actionButton: some View {
        Button {
            Task {
                await viewModel.runBenchmark()
            }
        } label: {
            HStack {
                Image(systemName: viewModel.isRunning ? "hourglass" : "play.circle.fill")
                Text(viewModel.isRunning ? "Running..." : (viewModel.totalScore != nil ? "Run Again" : "Start Test"))
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.isRunning ? Color.gray : Color.blue)
            .foregroundStyle(.white)
            .cornerRadius(12)
        }
        .disabled(viewModel.isRunning)
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .fontWeight(.bold)
            Text(text)
                .font(.subheadline)
        }
    }
}

struct ResultCard: View {
    let title: String
    let score: Double?
    let icon: String
    let color: Color
    var isTotal: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(isTotal ? .headline : .subheadline)
                    .fontWeight(isTotal ? .bold : .regular)
            }
            
            Spacer()
            
            if let score = score {
                Text(String(format: "%.2f", score))
                    .font(isTotal ? .title2 : .body)
                    .fontWeight(isTotal ? .bold : .semibold)
                    .foregroundStyle(color)
            }
        }
        .padding()
        .background(isTotal ? color.opacity(0.1) : Color(.systemBackground))
        .cornerRadius(10)
    }
}
