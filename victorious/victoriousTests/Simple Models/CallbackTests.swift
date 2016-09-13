//
//  CallbackTests.swift
//  victorious
//
//  Created by Jarod Long on 8/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class CallbackTests: XCTestCase {
    func testCallback() {
        var voidCallback = Callback<Void>()
        var voidCallbackCount1 = 0
        var voidCallbackCount2 = 0
        
        voidCallback.add {
            voidCallbackCount1 += 1
        }
        
        XCTAssertEqual(voidCallbackCount1, 0)
        voidCallback.call()
        XCTAssertEqual(voidCallbackCount1, 1)
        
        voidCallback.add {
            voidCallbackCount2 += 1
        }
        
        XCTAssertEqual(voidCallbackCount1, 1)
        XCTAssertEqual(voidCallbackCount2, 0)
        voidCallback.call()
        XCTAssertEqual(voidCallbackCount1, 2)
        XCTAssertEqual(voidCallbackCount2, 1)
        
        var paramCallback = Callback<String>()
        var paramCallbackValue: String?
        
        paramCallback.add { value in
            paramCallbackValue = value
        }
        
        XCTAssertNil(paramCallbackValue)
        paramCallback.call("yo")
        XCTAssertEqual(paramCallbackValue, "yo")
    }
}
