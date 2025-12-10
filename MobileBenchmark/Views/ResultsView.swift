//
//  ResultsView.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import SwiftUI

struct ResultsView: View {
    let result: BenchmarkResult

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                globalScoreSection
                
                individualScoresSection
                
                metadataSection
            }
            .padding()
        }
        .navigationTitle("Detailed Results")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var globalScoreSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 50))
                .foregroundStyle(.yellow.gradient)
            
            Text("Global Score")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text(String(format: "%.2f", result.globalScore))
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var individualScoresSection: some View {
        VStack(spacing: 12) {
            Text("Individual Scores")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ScoreRow(
                    icon: "cpu",
                    title: "Single-Threaded CPU",
                    score: result.singleThreadedCPUScore,
                    color: .blue
                )
                
                ScoreRow(
                    icon: "cpu.fill",
                    title: "Multi-Threaded CPU",
                    score: result.multiThreadedCPUScore,
                    color: .orange
                )
                
                ScoreRow(
                    icon: "dice.fill",
                    title: "GPU Score",
                    score: result.gpuScore,
                    color: .purple
                )
                
                ScoreRow(
                    icon: "memorychip",
                    title: "RAM Score",
                    score: result.ramScore,
                    color: .green
                )
                
                ScoreRow(
                    icon: "internaldrive",
                    title: "Storage Score",
                    score: result.storageScore,
                    color: .cyan
                )
            }
        }
    }
    
    private var metadataSection: some View {
        VStack(spacing: 12) {
            Text("Test Information")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 8) {
                InfoRow(label: "Device", value: result.deviceInfo.model)
                InfoRow(label: "iOS Version", value: result.deviceInfo.systemVersion)
                InfoRow(label: "Test Date", value: result.timestamp.formatted(date: .long, time: .shortened))
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .cornerRadius(12)
        }
    }
}

struct ScoreRow: View {
    let icon: String
    let title: String
    let score: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Text(String(format: "%.2f", score))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}
