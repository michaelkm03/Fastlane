//
//  VTabScaffoldViewControllerDoesNotAutoShowLoginTests.swift
//  victorious
//
//  Created by Michael Sena on 9/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation


class VTabScaffoldViewControllerDoesNotAutoShowLoginTests: VictoriousTestCase {
    
    override var testDescription: String {
        return "Tests some configurations of the scaffold."
    }
    
    override func beforeAll() {
        super.beforeAll()
        
        self.logOutAndResetSession()
    }
    
    override func configureTemplate(defaultTemplateDecorator: VTemplateDecorator) {
        print("configuring scaffold tests!")
        defaultTemplateDecorator.setTemplateValue(NSNumber(bool: false), forKeyPath: "scaffold/showLoginOnStartup")
        self.addStep("set scaffold/showLoginOnStartup in template to false")
    }
    
    func testDoesNotAutoShow() {
        self.addStep("look for a regsiter button")
        let registerButtonExists = self.tester().tryFindingViewWithAccessibilityLabel(VAutomationIdentifierLRegistrationEmail, error: nil)
        XCTAssertFalse(registerButtonExists, "We should not find a register button!")
    }
    
}

