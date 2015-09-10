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
    
    override func configureTemplate(defaultTemplateDecorator: VTemplateDecorator) {
        defaultTemplateDecorator.setTemplateValue(NSNumber(bool: true), forKeyPath: "scaffold/showLoginOnStartup")
        self.addStep("set scaffold/showLoginOnStartup in template to true")
    }
    
    func testAutoShowLogin() {
        self.addStep("look for a regsiter button")
        self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierLRegistrationEmail )
    }
    
}
