//
//  TabulaKitTests.swift
//  TabulaKitTests
//
//  Created by Pedro José Pereira Vieito on 08/04/2019.
//  Copyright © 2019 Pedro José Pereira Vieito. All rights reserved.
//

import XCTest
import FoundationKit
import TabulaKit

class TabulaKitTests: XCTestCase {
    static let resources = [
        "A606EDB3-C62E-41E1-985D-C94FF4F76FB6"
    ]
    
    static let testBundle = Bundle.currentSourceFileDirectoryBundle()
    
    func testTabula() throws {
        for itemName in TabulaKitTests.resources {
            let itemURL = TabulaKitTests.testBundle.url(forResource: itemName, withExtension: "pdf")!
            let itemPDF = try TabulaPDF(contentsOf: itemURL)
            let itemTables = try itemPDF.extractTables()
        
            let itemResultsURL = TabulaKitTests.testBundle.url(forResource: itemName, withExtension: "json")!
            let itemResultsData = try Data(contentsOf: itemResultsURL)
            let itemResults = try JSONDecoder().decode([[[String?]]].self, from: itemResultsData)
            XCTAssertEqual(itemTables, itemResults)
        }
    }
}
