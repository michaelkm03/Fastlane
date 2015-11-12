//
//  ImageSearchResultTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class ImageSearchResultTests: XCTestCase {
    
    func testJSONParsing() {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("ImageSearchResult", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        guard let imageSearchResult = ImageSearchResult(json: JSON(data: mockData)) else {
            XCTFail("Image search result initializer failed")
            return
        }
        XCTAssertEqual(imageSearchResult.imageURL, NSURL(string: "http://www.myprosurfer.co.uk/wp-content/uploads/surfer-420x261.jpg")!)
        XCTAssertEqual(imageSearchResult.thumbnailURL, NSURL(string: "http://tse4.mm.bing.net/th?id=OIP.Md0a950fb482ba6aaf969b912b6e85bcco0&pid=15.1&H=99&W=160")!)
    }
}
