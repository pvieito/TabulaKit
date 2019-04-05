//
//  TabulaPDF+OutputFormat.swift
//  TabulaKit
//
//  Created by Pedro José Pereira Vieito on 05/04/2019.
//  Copyright © 2019 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension TabulaPDF {
    enum OutputFormat: String {
        case csv
        case tsv
        case json
        
        static let `default`: OutputFormat = .json
    }
}

extension TabulaPDF.OutputFormat {
    var tabulaCode: String {
        return self.rawValue.uppercased()
    }
}
