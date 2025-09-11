//
//  OutputFormat.swift
//  TabulaTool
//
//  Created by Pedro José Pereira Vieito on 12/04/2020.
//  Copyright © 2020 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import ArgumentParser

enum OutputFormat: String, CaseIterable, ExpressibleByArgument {
    case json
    case jsonl
    case csv

    static let `default`: OutputFormat = .csv
}
