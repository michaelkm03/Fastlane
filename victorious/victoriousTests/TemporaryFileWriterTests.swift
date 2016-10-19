//
//  TemporaryFileWriterTests.swift
//  victorious
//
//  Created by Sebastian Nystorm on 12/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest

@testable import victorious

class TemporaryFileWriterTests: XCTestCase {

    private let testData = "An ordinary family man, geologist, and Mormon, Soren Johansson has always believed he’ll be reunited with his loved ones after death in an eternal hereafter. Then, he dies. Soren wakes to find himself cast by a God he has never heard of into a Hell whose dimensions he can barely grasp: a vast library he can only escape from by finding the book that contains the story of his life.".data(using: .utf8)!
    private let emptyData = Data()

    func testWritingFiles() {
        do {
            let fileName = "testfile"
            let fileExtension = "txt"
            let filePath = try TemporaryFileWriter.writeTemporaryData(testData, fileExtension: fileExtension, fileName: fileName)

            XCTAssertTrue(filePath.isFileURL, "URL returned should be a file URL, not -> \(filePath)")
            XCTAssertTrue(filePath.absoluteString.hasSuffix("\(fileName).\(fileExtension)"), "File name with extension should be present in file path -> \(filePath)")
        } catch {
            XCTFail("Writing a temp file to disk should not throw. Error -> \(error)")
        }
    }

    func testFailingToWriteFile() {
        if let _ = try? TemporaryFileWriter.writeTemporaryData(emptyData) {
            XCTFail("Error should be thrown for trygint to write empty data to disk.")
            return
        }
    }
}
