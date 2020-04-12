//
//  main.swift
//  TabulaTool
//
//  Created by Pedro José Pereira Vieito on 05/04/2019.
//  Copyright © 2019 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import FoundationKit
import LoggerKit
import PythonKit
import TabulaKit
import ArgumentParser

struct TabulaTool: ParsableCommand {
    static var configuration: CommandConfiguration {
        return CommandConfiguration(commandName: String(describing: Self.self))
    }
    
    @Option(name: .shortAndLong, parsing: .upToNextOption, help: "Input item.")
    var input: Array<String>
    
    @Option(name: .long, help: "Table index.")
    var tableIndex: Int?
    
    @Option(name: .long, parsing: .upToNextOption, help: "Column indexes.")
    var columnIndexes: Array<Int>
    
    @Option(name: .long, parsing: .upToNextOption, help: "Column names.")
    var columnNames: Array<String>

    @Option(name: .long, parsing: .upToNextOption, help: "Row indexes.")
    var rowIndexes: Array<Int>

    @Option(name: .long, help: "Output format.")
    var outputFormat: OutputFormat?

    @Flag(name: .shortAndLong, help: "Verbose mode.")
    var verbose: Bool
    
    func validate() throws {
        guard !self.input.isEmpty else {
            throw ValidationError("No input specified")
        }
    }
    
    func run() throws {
        do {
            Logger.logMode = .commandLine
            Logger.logLevel = self.verbose ? .debug : .info

            let pd = try Python.attemptImport("pandas")
            var extractedItemsTable = pd.DataFrame()

            for inputURL in self.input.pathURLs {
                Logger.log(debug: "Processing “\(inputURL.lastPathComponent)” tables...")

                let tabula = try TabulaPDF(contentsOf: inputURL)
                let extractedTables = try tabula.extractTables()
                var extractedTable = PythonObject(extractedTables[tableIndex ?? 0])
                extractedTable = pd.DataFrame(extractedTable)

                if !self.columnIndexes.isEmpty {
                    extractedTable = extractedTable[self.columnIndexes]
                }
                if !self.rowIndexes.isEmpty {
                    extractedTable = extractedTable.iloc[self.rowIndexes]
                }
                if !self.columnNames.isEmpty {
                    extractedTable.columns = PythonObject(self.columnNames)
                }

                extractedTable["source_filename"] = PythonObject(inputURL.deletingPathExtension().lastPathComponent)
                extractedItemsTable = extractedItemsTable.append(extractedTable)

                Logger.log(debug: "Extraction of item “\(inputURL.lastPathComponent)” completed with results: “\(extractedTable.to_json(orient: "records"))”")

                Logger.log(debug: "Extraction of item “\(inputURL.lastPathComponent)” completed with results: “\(extractedTable)”")
            }

            Logger.log(success: "Table extraction completed successfully for input items.")

            extractedItemsTable.set_index("source_filename", inplace: true)
            extractedItemsTable.sort_index(inplace: true)

            let outputFormat = self.outputFormat ?? .default
            let outputString: String

            switch outputFormat {
            case .csv:
                outputString = String(extractedItemsTable.to_csv())!
            case .json:
                outputString = String(extractedItemsTable.reset_index().to_json(orient: "records"))!
            }

            print(outputString)
        }
        catch {
            Logger.log(fatalError: error)
        }
    }
}

TabulaTool.main()
