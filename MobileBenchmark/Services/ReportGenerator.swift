//
//  ReportGenerator.swift
//  MobileBenchmark
//
//  Created by Murariu Georgiana-Roxana on 22.11.2025.
//

import Foundation

final class ReportGenerator {
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    func save(result: BenchmarkResult) -> URL? {
        guard let data = try? encoder.encode(result) else { return nil }
        
        let url = FileManager.default.documentsDirectory
            .appendingPathComponent("benchmark-\(result.id.uuidString).json")
        
        try? data.write(to: url)
        return url
    }
    
    func loadAllResults() -> [BenchmarkResult] {
        let documentsURL = FileManager.default.documentsDirectory
        
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: documentsURL,
            includingPropertiesForKeys: nil
        ) else { return [] }
        
        let results = files
            .filter { $0.pathExtension == "json" && $0.lastPathComponent.hasPrefix("benchmark-") }
            .compactMap { url -> BenchmarkResult? in
                guard let data = try? Data(contentsOf: url),
                      let result = try? decoder.decode(BenchmarkResult.self, from: data)
                else { return nil }
                return result
            }
            .sorted { $0.timestamp > $1.timestamp }
        
        return results
    }
    
    func deleteResult(_ result: BenchmarkResult) {
        let url = FileManager.default.documentsDirectory
            .appendingPathComponent("benchmark-\(result.id.uuidString).json")
        try? FileManager.default.removeItem(at: url)
    }
    
    func clearAllResults() {
        let results = loadAllResults()
        results.forEach { deleteResult($0) }
    }
}

private extension FileManager {
    var documentsDirectory: URL {
        urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
