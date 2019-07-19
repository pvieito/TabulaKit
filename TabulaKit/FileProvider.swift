//
//  FileProvider.swift
//  TabulaKit
//
//  Created by Pedro José Pereira Vieito on 05/04/2019.
//  Copyright © 2019 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

protocol FileProvider {
    func provideFileURL(completionHandler: (URL) throws -> Void) throws
}

extension URL: FileProvider {
    func provideFileURL(completionHandler: (URL) throws -> Void) throws {
        try completionHandler(self)
    }
}

extension Data: FileProvider {
    func provideFileURL(completionHandler: (URL) throws -> Void) throws {
        let temporaryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("pdf")
        try self.write(to: temporaryURL)
        try completionHandler(temporaryURL)
        try FileManager.default.removeItem(at: temporaryURL)
    }
}
