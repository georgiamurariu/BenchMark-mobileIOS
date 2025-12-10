//
//  BenchmarkChart.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import SwiftUI
import Charts

struct BenchmarkChart: View {
    let title: String
    let dataPoints: [BenchmarkDataPoint]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            if dataPoints.isEmpty {
                emptyStateView
            } else {
                chartView
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            
            Text("Run benchmark to see data")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(height: 180)
        .frame(maxWidth: .infinity)
    }
    
    private var chartView: some View {
        Chart(dataPoints) { point in
            LineMark(
                x: .value("Size", point.sizeLabel),
                y: .value("Time (ms)", point.timeMs)
            )
            .foregroundStyle(color)
            .lineStyle(StrokeStyle(lineWidth: 3))
            .symbol {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            }
            
            AreaMark(
                x: .value("Size", point.sizeLabel),
                y: .value("Time (ms)", point.timeMs)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [color.opacity(0.3), color.opacity(0.1), color.opacity(0.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .chartYAxisLabel("Execution Time (ms)", alignment: .center)
        .chartXAxisLabel("Input Size", alignment: .center)
        .frame(height: 180)
    }
}
