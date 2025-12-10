//
//  ResultProcessor.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import Foundation

final class ResultProcessor {
    func globalScore(cpu: Double, gpu: Double, ram: Double, storage: Double) -> Double {
        let product = cpu * gpu * ram * storage
        return pow(product, 1.0 / 4.0)
    }
}
