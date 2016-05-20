//
//  ViewedContentTests.swift
//  victorious
//
//  Created by Vincent Ho on 5/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@testable import VictoriousIOSSDK
import XCTest

class ViewedContentTests: XCTestCase {
    
    func testValid() {
        guard let viewedContent: ViewedContent = createViewedContentFromJSON(fileName: "ViewedContent") else {
            XCTFail("Failed to create a ViewedContent")
            return
        }
        
        XCTAssertNotNil(viewedContent.content, "Content should not be nil")
        XCTAssertNotNil(viewedContent.author, "Author should not be nil")
    }
    
    func testInvalid() {
        let viewedContent = createViewedContentFromJSON(fileName: "InvalidViewedContent")
        
        XCTAssertNil(viewedContent, "Viewed content should not have been created with an invalid JSON")
        
    }
    
    private func createViewedContentFromJSON(fileName fileName: String) -> ViewedContent? {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource(fileName, withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return nil
        }
        
        return ViewedContent(json: JSON(data: mockData))
    }
    
}
