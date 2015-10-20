
//
//  victoriousUITests.swift
//  victoriousUITests
//
//  Created by Carol Guerra on 10/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest

class victoriousUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        self.appStart()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func appStart() {
        
        let app = XCUIApplication()
        app.buttons["Registration Email"].tap()
        app.textFields["Signup Email Field"].typeText("carol@test.com")
        
        let signupPasswordFieldSecureTextField = app.secureTextFields["Signup Password Field"]
        signupPasswordFieldSecureTextField.tap()
        signupPasswordFieldSecureTextField.typeText("password")
        app.typeText("\n")
        
        let signupUsernameFieldTextField = app.textFields["Signup Username Field"]
        signupUsernameFieldTextField.tap()
        signupUsernameFieldTextField.typeText("Carol test")
        app.navigationBars["VModernEnterNameView"].buttons["Next"].tap()
        app.navigationBars["VEnterProfilePictureCameraView"].buttons["Next"].tap()
        app.navigationBars["VSuggestedUsersView"].buttons["Done"].tap()
        app.buttons["Welcome Dismiss"].tap()
        //app.alerts["\U201cdebug-victorious\U201d Would Like to Send You Notifications"].collectionViews.buttons["OK"].tap()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let text = "hello "
        
        let app = XCUIApplication()
        app.tabBars.buttons["Menu Create"].tap()
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.staticTexts["TEXT"].tap()
        app.alerts.collectionViews.buttons["OK"].tap()
        
        let textPostEditableMainFieldTextView = app.textViews["Text Post Editable Main Field"]
        textPostEditableMainFieldTextView.tap()
        textPostEditableMainFieldTextView.typeText(text)
        app.typeText("\n")
        collectionViewsQuery.cells.otherElements.containingType(.StaticText, identifier:"#surfer").childrenMatchingType(.Button).element.tap()
        app.navigationBars["Editor"].buttons["Publish"].tap()
        app.buttons["Recent"].tap()

        //find out how to select a UIcolletionViewCell from a UIcollectionView by the test like "hello" or nsindexpath, create a variable and then repace it and compare
        
        
            }
    
}
