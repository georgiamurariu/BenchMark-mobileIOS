//
//  DeviceInfoCard.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import SwiftUI

struct DeviceInfoCard: View {
    let title: String
    let rows: [(String, String)]

    var body: some View {
        GroupBox(title) {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(0..<rows.count, id: \.self) { i in
                    HStack {
                        Text(rows[i].0 + ":").bold()
                        Spacer()
                        Text(rows[i].1)
                    }
                }
            }
        }
    }
}
