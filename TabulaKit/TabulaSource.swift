//
//  TabulaPDF+Source.swift
//  TabulaKit
//
//  Created by Pedro José Pereira Vieito on 05/04/2019.
//  Copyright © 2019 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

protocol TabulaSource {
    func validFileURL(completionHandler: (URL) throws -> ()) throws
}

extension URL: TabulaSource {
    func validFileURL(completionHandler: (URL) throws -> ()) throws {
        try completionHandler(self)
    }
}

extension Data: TabulaSource {
    func validFileURL(completionHandler: (URL) throws -> ()) throws {
        let temporaryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("pdf")
        try self.write(to: temporaryURL)
        try completionHandler(temporaryURL)
        try FileManager.default.removeItem(at: temporaryURL)
    }
}
