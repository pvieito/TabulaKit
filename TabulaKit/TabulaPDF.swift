//
//  TabulaPDF.swift
//  TabulaKit
//
//  Created by Pedro José Pereira Vieito on 05/04/2019.
//  Copyright © 2019 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import FoundationKit

public struct TabulaPDF {
    private let source: FileProvider
    private var guess: Bool = true

    /// PDF pages from where to extract the tables.
    public var pages: [Int] = [1]

    /// PDF password.
    public var password: String?

    /// Initializes a `TabulaPDF` instance.
    ///
    /// - Parameter url: PDF document file.
    /// - Throws: Errors reading the file.
    public init(contentsOf url: URL) throws {
        if url.isFileURL && FileManager.default.fileExists(at: url) {
            self.source = url
        }
        else {
            self.source = try Data(contentsOf: url)
        }
    }
}

extension TabulaPDF {
    private static var bundle: Bundle {
        return Bundle.currentModuleBundle()
    }

    private static let javaTabulaVersion = "1.0.2"

    private static var javaTabulaArchive: URL {
        return bundle.url(forResource: "Tabula-\(javaTabulaVersion)", withExtension: "jar")!
    }

    private func buildOptions(outputFormat: OutputFormat) -> [String] {
        var buildOptions: [String] = []
        buildOptions += ["--silent"]
        buildOptions += ["--format", outputFormat.tabulaCode]
        buildOptions += ["--pages", pages.map(String.init).joined(separator: ",")]

        if self.guess {
            buildOptions += ["--guess"]
        }

        if let password = self.password {
            buildOptions += ["--password", password]
        }

        return buildOptions
    }
}

extension TabulaPDF {
    private func runJavaTabula(
        javaOptions: [String] = [],
        outputFormat: OutputFormat = .json) throws -> Data {
        let javaOptions = javaOptions + [
            "-Djava.awt.headless=true",
            "-Dorg.slf4j.simpleLogger.defaultLogLevel=off",
            "-Dorg.apache.commons.logging.Log=org.apache.commons.logging.impl.NoOpLog",
            "-Dfile.encoding=UTF8",
        ]

        var outputData = Data()

        try self.source.provideFileURL { url in
            let tabulaPath = TabulaPDF.javaTabulaArchive.path

            var arguments: [String] = []
            arguments += javaOptions + ["-jar", tabulaPath]
            arguments += self.buildOptions(outputFormat: outputFormat)
            arguments += [url.path]

            let process = try Process(executableName: "java", arguments: arguments)
            outputData = try process.runAndGetOutputData()
        }

        return outputData
    }
}

extension TabulaPDF {
    /// Extracts tables in the input PDF.
    ///
    /// - Returns: An array of tables with the text extracted from the PDF.
    /// - Throws: Any error during the extraction.
    public func extractTables() throws -> [[[String?]]] {
        let outputData = try self.runJavaTabula()
        guard let tables = try JSONSerialization.jsonObject(with: outputData) as? [Any] else {
            throw NSError(description: "Error decoding malformed `tabula` output.")
        }

        return tables.map { t -> [[String?]] in
            let t = t as! [String: Any]
            let a = t["data"] as! [[[String: Any]]]
            return a.map { $0.map { $0["text"] as? String } }
        }
    }
}
