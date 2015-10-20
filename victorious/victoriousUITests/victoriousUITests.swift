
//
//  victoriousUITests.swift
//  victoriousUITests
//
//  Created by Carol Guerra on 10/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest

class victoriousUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        
        setupLaunchArguments()
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func setupLaunchArguments() {
        app.launchArguments = ["always-show-login-screen"]
    }
    
    let loginTimeout = 10.0
    
    func testLogin() {
        
        app.navigationBars["VModernLandingView"].buttons["Log In"].tap()
        
        // Type wrong Info
        app.textFields["Login Username Field"].typeText("user@user.com")
        app.secureTextFields["Login Password Field"].tap()
        app.secureTextFields["Login Password Field"].typeText("password1")
        app.typeText("\n")
        
        // Login should have failed, tap alert view
        app.alerts["Login Failed"].collectionViews.buttons["OK"].tap()
        
        // Type right Info
        app.textFields["Login Username Field"].tap()
        app.textFields["Login Username Field"].typeText("user@user.com")
        app.secureTextFields["Login Password Field"].tap()
        app.secureTextFields["Login Password Field"].typeText("password")
        app.typeText("\n")
        
        // Make sure login screen still exists
        let loginScreen = app.navigationBars["VModernLoginView"]
        let doesNotExist = NSPredicate(format: "exists == false")
        expectationForPredicate(doesNotExist, evaluatedWithObject: loginScreen, handler: nil)
        waitForExpectationsWithTimeout(loginTimeout, handler: nil)
    }
}
