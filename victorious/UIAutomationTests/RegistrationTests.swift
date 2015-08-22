//
//  RegistrationTests.swift
//  victorious
//
//  Created by Patrick Lynch on 8/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit
import KIF

class RegistrationTests : VictoriousTestCase {
    
    override var testDescription: String {
        return "Tests basic login and registration, including errors for (1) invalid email, (2) invalid password and (3) email already registered."
    }
    
    func scrollToBottomOfTableView( accessibilityIdentifier: String ) {
        if let tableView = self.tester().waitForViewWithAccessibilityLabel( accessibilityIdentifier ) as? UITableView {
            let lastSection = max(tableView.numberOfSections()-1, 0)
            let lastRow = max(tableView.numberOfRowsInSection(lastSection)-1, 0)
            let indexPath = NSIndexPath(forRow: lastRow, inSection: lastSection)
            tableView.scrollToRowAtIndexPath( indexPath, atScrollPosition: .Middle, animated: false)
        }
    }
    
    func changeReturnKey() {
        // Change the return key type to avoid confusion with the "Next" button
        if let emailTextField = self.tester().waitForViewWithAccessibilityLabel(VAutomationIdentifierSignupEmailField) as? UITextField,
            let passwordTextField = self.tester().waitForViewWithAccessibilityLabel(VAutomationIdentifierSignupPasswordField) as? UITextField {
                emailTextField.returnKeyType = .Go;
                passwordTextField.returnKeyType = .Go;
        }
        else {
            XCTAssert( false )
        }
    }
    
    override func beforeEach() {
        super.beforeEach()
        
        // Logout
        self.tester().waitForViewWithAccessibilityLabel( "Menu Profile" ).tap()
        self.tester().waitForViewWithAccessibilityLabel( "Accessory Menu Settings" ).tap()
        self.scrollToBottomOfTableView( VAutomationIdentifierSettingsTableView )
        if self.elementExistsWithAccessibilityLabel( VAutomationIdentifierSettingsLogOut ) {
            self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierSettingsLogOut ).tap()
        }
        
        // Start each test with a login prompt
        self.tester().waitForTimeInterval( 2.0 )
        self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierSettingsLogIn ).tap()
    }
    
    func testLoginSuccess() {
        // Allow enough time so that the settings won't be confused with the "Log In" button from the login landing screen
        self.tester().waitForTimeInterval( 4.0 )
        self.tester().waitForTappableViewWithAccessibilityLabel( "Log In" ).tap()
        self.tester().enterText( "user@user.com", intoViewWithAccessibilityLabel: VAutomationIdentifierLoginUsernameField )
        self.tester().enterText( "password", intoViewWithAccessibilityLabel: VAutomationIdentifierLoginPasswordField )
        self.tester().waitForViewWithAccessibilityLabel( "Next" ).tap()
        
        // Logout button should be displayed
        self.scrollToBottomOfTableView( VAutomationIdentifierSettingsTableView )
        self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierSettingsLogOut )
    }
    
    func testSignupWithEmail() {
        self.tester().waitForTappableViewWithAccessibilityLabel( VAutomationIdentifierLRegistrationEmail ).tap()
        
        let randomInteger = 100000 + Int(arc4random() % 899999 )
        
        self.changeReturnKey()
        
        // Existing email
        self.tester().enterText( "user@user.com", intoViewWithAccessibilityLabel: VAutomationIdentifierSignupEmailField )
        self.tester().enterText( "\(randomInteger)\(randomInteger)", intoViewWithAccessibilityLabel: VAutomationIdentifierSignupPasswordField )
        self.tester().tapViewWithAccessibilityLabel( "Next" )
        self.tester().tapViewWithAccessibilityLabel( "OK" )
        self.tester().tapViewWithAccessibilityLabel( "Back" )
        self.tester().tapViewWithAccessibilityLabel( "Cancel" )
        self.tester().waitForTimeInterval( 5.0 )
        self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierSettingsLogIn ).tap()
        
        // Missing email
        self.tester().waitForTappableViewWithAccessibilityLabel( VAutomationIdentifierLRegistrationEmail ).tap()
        self.changeReturnKey()
        self.tester().enterText( "", intoViewWithAccessibilityLabel: VAutomationIdentifierSignupEmailField )
        self.tester().tapViewWithAccessibilityLabel( "Next" )
        let emailValidationText = self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierSignupEmailFieldValidation )
        XCTAssertFalse( emailValidationText.hidden )
        
        // Missing password
        self.tester().enterText( "user\(randomInteger)@user.com", intoViewWithAccessibilityLabel: VAutomationIdentifierSignupEmailField )
        self.tester().enterText( "", intoViewWithAccessibilityLabel: VAutomationIdentifierSignupPasswordField )
        self.tester().tapViewWithAccessibilityLabel( "Next" )
        let passwordValidationText = self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierSignupPasswordFieldValidation )
        XCTAssertFalse( passwordValidationText.hidden )
        
        // Valid email & password
        self.tester().enterText( "password", intoViewWithAccessibilityLabel: VAutomationIdentifierSignupPasswordField )
        self.tester().tapViewWithAccessibilityLabel( "Next" )
        
        self.tester().enterText( "Automated User \(randomInteger)", intoViewWithAccessibilityLabel: VAutomationIdentifierSignupUsernameField )
        self.tester().tapViewWithAccessibilityLabel( "Next" )
        
        self.tester().waitForTimeInterval( 12.0 )
        self.tester().tapViewWithAccessibilityLabel( "Next" )
        self.tester().tapViewWithAccessibilityLabel( "Skip" )
        self.tester().tapViewWithAccessibilityLabel( "Back" )
        
        // Logout button should be displayed
        self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierProfileUsernameTitle )
    }
}
