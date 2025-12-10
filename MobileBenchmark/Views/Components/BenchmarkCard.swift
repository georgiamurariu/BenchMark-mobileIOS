//
//  BenchmarkCard.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import SwiftUI

struct BenchmarkCard: View {
    let title: String
    let value: Double?
    let unit: String?

    init(title: String, value: Double?, unit: String? = nil) {
        self.title = title
        self.value = value
        self.unit = unit
    }

    var body: some View {
        GroupBox {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                if let value {
                    Text(String(format: "%.2f", value) + (unit != nil ? " \(unit!)" : ""))
                        .font(.title3).bold()
                } else {
                    Text("-")
                        .font(.title3).bold()
                }
            }
        }
    }
}
