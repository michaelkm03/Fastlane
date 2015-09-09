//
//  VTabScaffoldViewControllerTests.swift
//  victorious
//
//  Created by Michael Sena on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// These tests are broken up due to not having a hook before a test method is run and not wanting to wait any longer than necessary

class VTabScaffoldViewControllerAutoShowsLoginTests: LoggedOutVictoriousTestCase {
    
    override var testDescription: String {
        return "Tests some configurations of the scaffold."
    }
    
    override func configureTemplate(defaultTemplateDecorator: VTemplateDecorator) -> (VTemplateDecorator) {
        defaultTemplateDecorator.setTemplateValue(NSNumber(bool: true), forKeyPath: "scaffold/showLoginOnStartup")
        self.addStep("set scaffold/showLoginOnStartup in template to true")
        return defaultTemplateDecorator
    }
    
    func testAutoShowLogin() {
        self.addStep("look for a regsiter button")
        self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierLRegistrationEmail )
    }
    
}

class VTabScaffoldViewControllerDoesNotAutoShowLoginTests: LoggedOutVictoriousTestCase {
    
    override var testDescription: String {
        return "Tests some configurations of the scaffold."
    }
    
    override func configureTemplate(defaultTemplateDecorator: VTemplateDecorator) -> (VTemplateDecorator) {
        println("configuring scaffold tests!")
        defaultTemplateDecorator.setTemplateValue(NSNumber(bool: false), forKeyPath: "scaffold/showLoginOnStartup")
        self.addStep("set scaffold/showLoginOnStartup in template to false")
        return defaultTemplateDecorator
    }
    
    func testDoesNotAutoShow() {
        self.addStep("look for a regsiter button")
        let registerButtonExists = self.tester().tryFindingViewWithAccessibilityLabel(VAutomationIdentifierLRegistrationEmail, error: nil)
        XCTAssertFalse(registerButtonExists, "We should not find a register button!")
    }
    
}

