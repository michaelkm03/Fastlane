//
//  TutorialContentsRemoteOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 5/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
@testable import VictoriousIOSSDK

class TutorialContentsRemoteOperationTests: BaseFetcherOperationTestCase {
    
    private lazy var networkResults: [Content] = {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("ViewedContentsResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return []
        }
        let json = JSON(data: mockData)["payload", "viewed_contents"].arrayValue
        let results = json.flatMap { Content(json: $0) }
        
        return results
    }()
    
    func testResults() {
        let operation = TutorialContentsRemoteOperation(urlString: "http://www.victorious.com")
        operation.requestExecutor = TestRequestExecutor(result: networkResults)
        operation.main()
        
        let fetchedContents = operation.results as? [Content]
        
        XCTAssertEqual(fetchedContents?.count, 2)
        XCTAssertEqual(fetchedContents?.first?.id, "20711")
        XCTAssertEqual(fetchedContents?.last?.id, "20712")
    }
}
