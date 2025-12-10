//
//  HomeView.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import SwiftUI

struct HomeView: View {
    @State private var deviceInfo: DeviceInfo?
    private let analyzer = DeviceAnalyzer()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    
                    if let info = deviceInfo {
                        deviceSpecsSection(info: info)
                    }
                    
                    benchmarkMenuSection
                    
                    quickActionsSection
                }
                .padding()
            }
            .navigationTitle("Mobile Benchmark")
            .onAppear {
                deviceInfo = analyzer.getDeviceInfo()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "speedometer")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)
            
            Text("iPhone Benchmark Suite")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Test your device's performance")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical)
    }
    
    private func deviceSpecsSection(info: DeviceInfo) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Device Specifications")
                    .font(.headline)
                Spacer()
                NavigationLink {
                    DeviceInfoView(info: info)
                } label: {
                    Label("Details", systemImage: "info.circle")
                        .font(.caption)
                }
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                SpecCard(icon: "iphone", title: "Model", value: info.model)
                SpecCard(icon: "cpu", title: "CPU Cores", value: "\(info.coreCount)")
                SpecCard(icon: "memorychip", title: "RAM", value: formatBytes(info.totalMemory))
                SpecCard(icon: "internaldrive", title: "Storage", value: formatBytes(info.storageTotal))
                SpecCard(icon: "battery.100", title: "Battery", value: "\(Int(info.batteryLevel * 100))%")
                SpecCard(icon: "thermometer.medium", title: "Thermal", value: info.thermalState)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var benchmarkMenuSection: some View {
        VStack(spacing: 12) {
            Text("Benchmark Tests")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                NavigationLink {
                    SingleThreadedBenchmarkView()
                } label: {
                    BenchmarkMenuCard(
                        icon: "cpu",
                        title: "Single-Threaded CPU",
                        description: "Test single-core performance",
                        color: .blue
                    )
                }
                
                NavigationLink {
                    MultithreadedBenchmarkView()
                } label: {
                    BenchmarkMenuCard(
                        icon: "cpu.fill",
                        title: "Multi-Threaded CPU",
                        description: "Test parallel processing",
                        color: .orange
                    )
                }
                
                NavigationLink {
                    GPUBenchmarkView()
                } label: {
                    BenchmarkMenuCard(
                        icon: "dice.fill",
                        title: "GPU Benchmark",
                        description: "Test graphics performance",
                        color: .purple
                    )
                }
                
                NavigationLink {
                    RAMBenchmarkView()
                } label: {
                    BenchmarkMenuCard(
                        icon: "memorychip",
                        title: "RAM Benchmark",
                        description: "Test memory performance",
                        color: .green
                    )
                }
                
                NavigationLink {
                    StorageBenchmarkView()
                } label: {
                    BenchmarkMenuCard(
                        icon: "internaldrive",
                        title: "Storage Benchmark",
                        description: "Test disk I/O performance",
                        color: .cyan
                    )
                }
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            NavigationLink {
                DashboardView()
            } label: {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                    Text("Run All Benchmarks")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.blue.gradient)
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
            
            NavigationLink {
                ResultsHistoryView()
            } label: {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.title2)
                    Text("View Results History")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color(.systemGray5))
                .foregroundStyle(.primary)
                .cornerRadius(12)
            }
        }
    }
    
    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        formatter.allowedUnits = [.useGB, .useMB]
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

struct SpecCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                Spacer()
            }
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct BenchmarkMenuCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color.gradient)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
