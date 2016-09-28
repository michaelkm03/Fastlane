//
//  TemporaryFileWriter.swift
//  victorious
//
//  Created by Sebastian Nystorm on 20/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

struct TemporaryFileWriter {
    private static var temporaryWrittenFiles: [NSURL] = []

    /// Forces all temporary written files to be removed from disk.
    static func removeTemporaryFiles() {
        for temporaryFile in temporaryWrittenFiles {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(temporaryFile)
            } catch {
                Log.info("Failed to remove temporary file at URL -> \(temporaryFile) with error -> \(error)")
            }
        }
        temporaryWrittenFiles.removeAll()
    }

    /// Writes the raw data to disk atomically with a file extension and a fileName. If no extension is specified none is used, if no filename is specified a new unique one is generated.
    /// If the file write succeeds a path is returned else nil is returned.
    static func writeTemporaryData(data: NSData, fileExtension: String = "", fileName: String = NSProcessInfo.processInfo().globallyUniqueString) throws -> NSURL {
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("\(fileName).\(fileExtension)") ?? NSURL()

        do {
            try data.writeToURL(fileURL, options: .AtomicWrite)
        } catch {
            Log.warning("Failed to write a temporary file to disk with path -> \(fileURL.absoluteString) and error -> \(error)")
            throw error
        }

        temporaryWrittenFiles.append(fileURL)

        return fileURL
    }
}
