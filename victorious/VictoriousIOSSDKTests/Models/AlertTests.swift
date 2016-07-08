//
//  AlertTests.swift
//  victorious
//
//  Created by Patrick Lynch on 12/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class AlertTests: XCTestCase {
    
    func testValid() {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource("Alert", withExtension: "json" ),
            let mockData = NSData(contentsOfURL: url) else {
                XCTFail("Error reading mock json data" )
                return
        }
        guard let alert = Alert(json: JSON(data: mockData)) else {
            XCTFail("Alert initializer failed" )
            return
        }
        
        XCTAssertEqual( alert.alertID, "1341" )
        XCTAssertEqual( alert.type, AlertType.levelUp )
        XCTAssertEqual( NSDateFormatter.vsdk_defaultDateFormatter().stringFromDate( alert.dateAcknowledged!), "2015-12-18 20:40:43" )
        XCTAssertEqual( alert.parameters.backgroundVideoURL?.absoluteString, "http://www.video.com" )
        XCTAssertEqual( alert.parameters.description, "Level up!" )
        XCTAssertEqual( alert.parameters.title, "Alert Title" )
        XCTAssertEqual( alert.parameters.icons?.count, 1 )
        XCTAssertEqual( alert.parameters.icons?[0], NSURL(string: "http://i.imgur.com/ietHgk6.png") )
        XCTAssertEqual( alert.parameters.userFanLoyalty?.points, 100 )
        XCTAssertEqual( alert.parameters.userFanLoyalty?.level, 2 )
        XCTAssertEqual( alert.parameters.userFanLoyalty?.progress, 25 )
    }
}
