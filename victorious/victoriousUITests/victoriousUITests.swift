
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
        
        // Check if loading screen shows up
        XCTAssert(app.navigationBars["victorious.ModernLoadingView"].exists)
        
        // Login should have failed, tap alert view
        app.alerts["Login Failed"].collectionViews.buttons["OK"].tap()
        
        // Type right info
        app.textFields["Login Username Field"].tap()
        app.textFields["Login Username Field"].typeText("user@user.com")
        app.secureTextFields["Login Password Field"].tap()
        app.secureTextFields["Login Password Field"].typeText("password")
        app.typeText("\n")
        
        // Make sure last screen does not exist
        let loginScreen = app.navigationBars["VModernLoginView"]
        let doesNotExist = NSPredicate(format: "exists == false")
        expectationForPredicate(doesNotExist, evaluatedWithObject: loginScreen, handler: nil)
        waitForExpectationsWithTimeout(loginTimeout, handler: nil)
    }
    
    func testRegister() {
        
        app.buttons["Registration Email"].tap()
        
        let signupEmailFieldTextField = app.textFields["Signup Email Field"]
        signupEmailFieldTextField.tap()
        let randomEmail = "user\(self.generateRandomInteger())@user.com"
        signupEmailFieldTextField.typeText(randomEmail)
        
        let signupPasswordFieldSecureTextField = app.secureTextFields["Signup Password Field"]
        signupPasswordFieldSecureTextField.tap()
        signupPasswordFieldSecureTextField.typeText("password")
        app.typeText("\n")
        
        // Check if loading screen shows up
        XCTAssert(app.navigationBars["victorious.ModernLoadingView"].exists)
        
        app.textFields["Signup Username Field"].typeText("Test")
        app.navigationBars["VModernEnterNameView"].buttons["Next"].tap()
        app.navigationBars["VEnterProfilePictureCameraView"].buttons["Next"].tap()
        app.navigationBars["VSuggestedUsersView"].buttons["Done"].tap()
        
        // Make sure last screen does not exist
        let suggestedUsersScreen = app.navigationBars["VSuggestedUsersView"]
        let doesNotExist = NSPredicate(format: "exists == false")
        expectationForPredicate(doesNotExist, evaluatedWithObject: suggestedUsersScreen, handler: nil)
        waitForExpectationsWithTimeout(loginTimeout, handler: nil)
    }
    
    func testFacebookRegister() {
        
        app.buttons["Registration Facebook"].tap()
        
        let loadingScreen = app.navigationBars["victorious.ModernLoadingView"]

        // Check if loading screen shows up
        XCTAssert(loadingScreen.exists)
        
        // Make sure loading screen dismisses
        let doesNotExist = NSPredicate(format: "exists == false")
        expectationForPredicate(doesNotExist, evaluatedWithObject: loadingScreen, handler: nil)
        waitForExpectationsWithTimeout(loginTimeout, handler: nil)
    }
    
    func testTwitterRegister() {
        
        app.buttons["Registration Twitter"].tap()
        
        // If we have multiple Twitter accounts
        if app.navigationBars["VSelectorView"].exists {
            app.tables.elementBoundByIndex(0).cells.elementBoundByIndex(0).tap()
        }
        
        let loadingScreen = app.navigationBars["victorious.ModernLoadingView"]
        
        // Check if loading screen shows up
        XCTAssert(loadingScreen.exists)
        
        // Make sure loading screen dismisses
        let doesNotExist = NSPredicate(format: "exists == false")
        expectationForPredicate(doesNotExist, evaluatedWithObject: loadingScreen, handler: nil)
        waitForExpectationsWithTimeout(loginTimeout, handler: nil)
    }
    
    func generateRandomInteger() -> Int {
        return 100000 + Int(arc4random_uniform(899999))
    }
}
