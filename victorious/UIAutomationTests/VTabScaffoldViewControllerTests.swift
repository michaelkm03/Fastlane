//
//  VTabScaffoldViewControllerTests.swift
//  victorious
//
//  Created by Michael Sena on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class VTabScaffoldViewControllerAutoShowsLoginTests: VictoriousTestCase {
    
    override var testDescription: String {
        return "Tests some configurations of the scaffold."
    }
    
    override func beforeAll() {
        super.beforeAll()
    
        self.logOutAndResetSession()
    }
    
    func testAutoShowLogin() {
        self.addStep("look for a regsiter button")
        self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierLRegistrationEmail )
    }
    
}
