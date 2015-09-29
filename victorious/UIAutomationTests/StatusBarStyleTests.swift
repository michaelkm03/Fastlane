//
//  StatusBarStyleTests.swift
//  victorious
//
//  Created by Tian Lan on 9/29/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

class StatusBarStyleTests: VictoriousTestCase {
    override var testDescription: String {
        return "Tests status bar style matching navigation bar text color"
    }
    
    override func configureTemplate(defaultTemplateDecorator: VTemplateDecorator) {
        addStep("Configuring template to make all text.color white")
        let mainTextColor = [
            "red" : 255,
            "green" : 255,
            "blue" : 255,
            "alpha" : 255
        ]
        defaultTemplateDecorator.setValue(mainTextColor, forAllOccurencesOfKey: VDependencyManagerMainTextColorKey)
    }
    
    override func beforeAll() {
        super.beforeAll()
        logOutAndResetSession()
        loginAndDismissWelcomeIfPresent()
    }
    
    func testStatusBarStyle() {
        
        tester().waitForTimeInterval(2.0)
        addStep("Checking status bar style on scaffold")
        checkStatusBarStyle()
        
        addStep( "Select *IMAGE* from the creation menu." )
        tester().tapViewWithAccessibilityLabel("Menu Create")
        tester().tapViewWithAccessibilityLabel("Create Image")
        
        tester().waitForTimeInterval(2.0)
        addStep("Check status bar style for creation flow")
        checkStatusBarStyle()
    }
    
    private func checkStatusBarStyle() {
        let style = UIApplication.sharedApplication().statusBarStyle
        XCTAssert(style == .LightContent, "Status bar style should be .LightContent when navigation bar text color is white")
    }
}
