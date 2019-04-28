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
import CommandLineKit
import TabulaKit
import PythonKit

enum OutputFormat: String, CaseIterable {
    case json
    case csv
    
    static let `default`: OutputFormat = .csv
}

let inputOption = MultiStringOption(shortFlag: "i", longFlag: "input", required: true, helpMessage: "Input items.")
let tableIndexOption = IntOption(longFlag: "table-index", helpMessage: "Table index.")
let columnIndexesOption = MultiStringOption(longFlag: "column-indexes", helpMessage: "Column indexes.")
let columnNamesOption = MultiStringOption(longFlag: "column-names", helpMessage: "Column names.")
let rowIndexesOption = MultiStringOption(longFlag: "row-indexes", helpMessage: "Row indexes.")
let outputFormatOption = EnumOption<OutputFormat>(shortFlag: "f", longFlag: "output-format", helpMessage: "Output format.")
let verboseOption = BoolOption(shortFlag: "v", longFlag: "verbose", helpMessage: "Verbose mode.")
let helpOption = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Prints a help message.")

let cli = CommandLineKit.CommandLine()
cli.addOptions(inputOption, tableIndexOption, columnIndexesOption, columnNamesOption, rowIndexesOption, outputFormatOption, verboseOption, helpOption)

do {
    try cli.parse(strict: true)
}
catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

if helpOption.value {
    cli.printUsage()
    exit(0)
}

Logger.logMode = .commandLine
Logger.logLevel = verboseOption.value ? .debug : .info

guard let inputItems = inputOption.value?.pathURLs else {
    Logger.log(fatalError: "No input items specified.")
}

do {
    let pd = try Python.attemptImport("pandas")
    var extractedItemsTable = pd.DataFrame()

    for item in inputItems {
        Logger.log(debug: "Processing “\(item.lastPathComponent)” tables...")
        
        let tabula = try TabulaPDF(contentsOf: item)
        let extractedTables = try tabula.extractTables()
        var extractedTable = PythonObject(extractedTables[tableIndexOption.value ?? 0])
        extractedTable = pd.DataFrame(extractedTable)
        
        if let columnIndexes = columnIndexesOption.value?.compactMap(Int.init) {
            extractedTable = extractedTable[columnIndexes]
        }
        if let rowIndexes = rowIndexesOption.value?.compactMap(Int.init) {
            extractedTable = extractedTable.iloc[rowIndexes]
        }
        if let columnNames = columnNamesOption.value {
            extractedTable.columns = PythonObject(columnNames)
        }
        
        extractedTable["source_filename"] = PythonObject(item.deletingPathExtension().lastPathComponent)
        extractedItemsTable = extractedItemsTable.append(extractedTable)
        
        Logger.log(debug: "Extraction of item “\(item.lastPathComponent)” completed with results: “\(extractedTable.to_json(orient: "records"))”")

        Logger.log(debug: "Extraction of item “\(item.lastPathComponent)” completed with results: “\(extractedTable)”")
    }
    
    Logger.log(success: "Table extraction completed successfully for input items.")
    
    extractedItemsTable.set_index("source_filename", inplace: true)
    extractedItemsTable.sort_index(inplace: true)
    
    let outputFormat = outputFormatOption.value ?? .default
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
