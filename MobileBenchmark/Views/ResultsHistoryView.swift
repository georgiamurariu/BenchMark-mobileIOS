//
//  ResultsHistoryView.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import SwiftUI

struct ResultsHistoryView: View {
    @State private var results: [BenchmarkResult] = []
    @State private var showingDeleteAlert = false
    @State private var selectedResult: BenchmarkResult?
    
    private let reportGenerator = ReportGenerator()
    
    var body: some View {
        Group {
            if results.isEmpty {
                emptyStateView
            } else {
                resultsList
            }
        }
        .navigationTitle("Results History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !results.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Clear All", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .onAppear {
            loadResults()
        }
        .alert("Clear All Results?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                clearAllResults()
            }
        } message: {
            Text("This will permanently delete all saved benchmark results.")
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Results Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Run benchmarks to see results here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private var resultsList: some View {
        List {
            ForEach(results) { result in
                NavigationLink {
                    ResultDetailView(result: result)
                } label: {
                    ResultRow(result: result)
                }
            }
            .onDelete(perform: deleteResults)
        }
    }
    
    private func loadResults() {
        results = reportGenerator.loadAllResults()
    }
    
    private func deleteResults(at offsets: IndexSet) {
        for index in offsets {
            reportGenerator.deleteResult(results[index])
        }
        results.remove(atOffsets: offsets)
    }
    
    private func clearAllResults() {
        reportGenerator.clearAllResults()
        results = []
    }
}

struct ResultRow: View {
    let result: BenchmarkResult
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.deviceInfo.model)
                        .font(.headline)
                    
                    Text(result.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Global Score")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(String(format: "%.2f", result.globalScore))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                }
            }
            
            Divider()
                .padding(.vertical, 4)
            
            HStack(spacing: 16) {
                ScorePill(label: "ST CPU", score: result.singleThreadedCPUScore, color: .blue)
                ScorePill(label: "MT CPU", score: result.multiThreadedCPUScore, color: .orange)
                ScorePill(label: "GPU", score: result.gpuScore, color: .purple)
                ScorePill(label: "RAM", score: result.ramScore, color: .green)
                ScorePill(label: "Storage", score: result.storageScore, color: .cyan)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ScorePill: View {
    let label: String
    let score: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            Text(String(format: "%.0f", score))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

struct ResultDetailView: View {
    let result: BenchmarkResult
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                deviceInfoSection
                
                scoresSection
                
                timestampSection
            }
            .padding()
        }
        .navigationTitle("Result Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var deviceInfoSection: some View {
        VStack(spacing: 12) {
            Text("Device Information")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 8) {
                InfoRow(label: "Model", value: result.deviceInfo.model)
                InfoRow(label: "iOS Version", value: result.deviceInfo.systemVersion)
                InfoRow(label: "CPU", value: result.deviceInfo.cpuName)
                InfoRow(label: "CPU Cores", value: "\(result.deviceInfo.coreCount)")
                InfoRow(label: "GPU", value: result.deviceInfo.gpuName)
                InfoRow(label: "RAM", value: formatBytes(result.deviceInfo.totalMemory))
                InfoRow(label: "Storage", value: formatBytes(result.deviceInfo.storageTotal))
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .cornerRadius(12)
        }
    }
    
    private var scoresSection: some View {
        VStack(spacing: 12) {
            Text("Benchmark Scores")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                BenchmarkCard(title: "Single-Threaded CPU", value: result.singleThreadedCPUScore)
                BenchmarkCard(title: "Multi-Threaded CPU", value: result.multiThreadedCPUScore)
                BenchmarkCard(title: "GPU Score", value: result.gpuScore)
                BenchmarkCard(title: "RAM Score", value: result.ramScore)
                BenchmarkCard(title: "Storage Score", value: result.storageScore)
                
                Divider()
                
                BenchmarkCard(title: "Global Score", value: result.globalScore)
            }
        }
    }
    
    private var timestampSection: some View {
        VStack(spacing: 4) {
            Text("Benchmark Date")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(result.timestamp.formatted(date: .long, time: .shortened))
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        formatter.allowedUnits = [.useGB, .useMB]
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}
