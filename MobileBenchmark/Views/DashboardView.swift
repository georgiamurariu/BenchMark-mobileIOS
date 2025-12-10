//
//  DashboardView.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import SwiftUI

struct DashboardView: View {
    @State var vm = DashboardViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                
                if vm.isRunning {
                    runningSection
                } else if let result = vm.lastResult {
                    resultsSection(result: result)
                } else {
                    instructionsSection
                }
                
                actionButton
            }
            .padding()
        }
        .navigationTitle("Full Benchmark")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "gauge.high")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)
            
            Text("Complete System Benchmark")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Run all tests to get a comprehensive performance score")
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
            Label("This test includes:", systemImage: "info.circle.fill")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                TestItem(icon: "cpu", title: "CPU Benchmark", color: .blue)
                TestItem(icon: "dice.fill", title: "GPU Benchmark", color: .purple)
                TestItem(icon: "memorychip", title: "RAM Benchmark", color: .green)
                TestItem(icon: "internaldrive", title: "Storage Benchmark", color: .orange)
            }
            
            Text("The test may take a few minutes to complete")
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
            ProgressView(value: vm.progress) {
                Text("Running Benchmarks...")
                    .font(.headline)
            }
            .tint(.blue)
            
            Text("\(Int(vm.progress * 100))%")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.blue)
            
            Text("Please wait while tests are running")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func resultsSection(result: BenchmarkResult) -> some View {
        VStack(spacing: 12) {
            Text("Benchmark Results")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                BenchmarkCard(title: "Single-Threaded CPU", value: result.singleThreadedCPUScore)
                BenchmarkCard(title: "Multi-Threaded CPU", value: result.multiThreadedCPUScore)
                BenchmarkCard(title: "GPU Score", value: result.gpuScore)
                BenchmarkCard(title: "RAM Score", value: result.ramScore)
                BenchmarkCard(title: "Storage Score", value: result.storageScore)
                
                Divider()
                    .padding(.vertical, 4)
                
                BenchmarkCard(title: "Global Score", value: result.globalScore)
            }
            
            NavigationLink {
                ResultsView(result: result)
            } label: {
                HStack {
                    Text("View Detailed Results")
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                .cornerRadius(10)
            }
            .padding(.top, 8)
            
            if let info = vm.deviceInfo {
                NavigationLink {
                    DeviceInfoView(info: info)
                } label: {
                    HStack {
                        Text("Device Information")
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color(.systemGroupedBackground))
                    .cornerRadius(10)
                }
            }
        }
    }
    
    private var actionButton: some View {
        Button {
            Task {
                await vm.startBenchmarks()
            }
        } label: {
            HStack {
                Image(systemName: vm.isRunning ? "hourglass" : "play.circle.fill")
                Text(vm.isRunning ? "Running..." : (vm.lastResult != nil ? "Run Again" : "Start Full Benchmark"))
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(vm.isRunning ? Color.gray : Color.blue)
            .foregroundStyle(.white)
            .cornerRadius(12)
        }
        .disabled(vm.isRunning)
    }
}

struct TestItem: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
        }
    }
}
