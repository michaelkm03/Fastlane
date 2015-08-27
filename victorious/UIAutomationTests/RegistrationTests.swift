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
        return "Tests basic login and registration, including error states."
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
        
        self.logoutIfLoggedIn()
        
        self.addStep( "Select *Log In* button to present the login flow.")
        self.tester().waitForTimeInterval( 4.0 )
    }
    
    func testLoginSuccess() {
        self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierSettingsLogIn ).tap()
        // Allow enough time so that the settings won't be confused with the "Log In" button from the login landing screen
        self.tester().waitForTimeInterval( 4.0 )
        
        self.addStep( "Select *Log In* option from modern login prompt." )
        self.tester().waitForTappableViewWithAccessibilityLabel( "Log In" ).tap()
        
        let email = "user@user.com", password = "password"
        self.addStep( "Log in with previously-registered user account: \(email)/\(password)" )
        self.tester().enterText( email, intoViewWithAccessibilityLabel: VAutomationIdentifierLoginUsernameField )
        self.tester().enterText( password, intoViewWithAccessibilityLabel: VAutomationIdentifierLoginPasswordField )
        self.tester().waitForViewWithAccessibilityLabel( "Next" ).tap()
        
        self.addStep( "If login in was successful, the *Log Out* button should now be visible" )
        self.tester().scrollToBottomOfTableView( VAutomationIdentifierSettingsTableView )
        self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierSettingsLogOut )
    }
    
    func generateRandomInteger() -> Int {
        return 100000 + Int(arc4random_uniform(899999))
    }
    
    func testSignupWithEmail() {
        self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierSettingsLogIn ).tap()
        self.tester().waitForTappableViewWithAccessibilityLabel( VAutomationIdentifierLRegistrationEmail ).tap()
        
        let randomCaptionInteger = self.generateRandomInteger()
        
        self.changeReturnKey()
        
        let email = "user@user.com"
        self.addStep( "Log in with existing user account (\(email)) and wrong password." )
        self.tester().enterText( email, intoViewWithAccessibilityLabel: VAutomationIdentifierSignupEmailField )
        self.tester().enterText( "\(randomCaptionInteger)\(randomCaptionInteger)", intoViewWithAccessibilityLabel: VAutomationIdentifierSignupPasswordField )
        self.tester().tapViewWithAccessibilityLabel( "Next" )
        self.addStep( "Ensure that error alert appears and dismiss by pressing *OK*." )
        self.tester().tapViewWithAccessibilityLabel( "OK" )
        self.tester().tapViewWithAccessibilityLabel( "Back" )
        self.addStep( "Press *Cancel* to dismiss login prompt and return to previous screen." )
        self.tester().waitForTimeInterval( 5.0 )
        self.tester().tapViewWithAccessibilityLabel( "Cancel" )
        
        self.addStep( "Select *Log In* button" )
        self.tester().waitForTimeInterval( 5.0 )
        self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierSettingsLogIn ).tap()
        
        // Missing email
        self.addStep( "Select *Sign up with Email*" )
        self.tester().waitForTappableViewWithAccessibilityLabel( VAutomationIdentifierLRegistrationEmail ).tap()
        self.changeReturnKey()
        self.tester().enterText( "", intoViewWithAccessibilityLabel: VAutomationIdentifierSignupEmailField )
        self.addStep( "Enter an email to trigger validation error." )
        self.tester().tapViewWithAccessibilityLabel( "Next" )
        self.addStep( "Ensure that the validation error message appears." )
        let emailValidationText = self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierSignupEmailFieldValidation )
        XCTAssertFalse( emailValidationText.hidden )
        
        // Missing password
        let randomEmail = "user\(self.generateRandomInteger())@user.com"
        self.addStep( "Enter a random email (e.g. \(randomEmail)) but leave password blank." )
        self.tester().enterText( randomEmail, intoViewWithAccessibilityLabel: VAutomationIdentifierSignupEmailField )
        self.tester().enterText( "", intoViewWithAccessibilityLabel: VAutomationIdentifierSignupPasswordField )
        self.tester().tapViewWithAccessibilityLabel( "Next" )
        self.addStep( "Ensure that the validation error message appears." )
        let passwordValidationText = self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierSignupPasswordFieldValidation )
        XCTAssertFalse( passwordValidationText.hidden )
        
        // Valid email & password
        self.addStep( "Enter a valid password for the randomly generated email provided before" )
        self.tester().enterText( "password", intoViewWithAccessibilityLabel: VAutomationIdentifierSignupPasswordField )
        self.tester().tapViewWithAccessibilityLabel( "Next" )
        
        let username = "\(self.generateRandomInteger()) \(self.generateRandomInteger())"
        self.tester().enterText( username, intoViewWithAccessibilityLabel: VAutomationIdentifierSignupUsernameField )
        self.addStep( "Add a randomly generated user name (e.g. \(username))" )
        self.tester().tapViewWithAccessibilityLabel( "Next" )
        
        self.tester().waitForTimeInterval( 12.0 )
        self.addStep( "Skipping add photo." )
        self.tester().tapViewWithAccessibilityLabel( "Next" )
        
        self.tester().waitForTimeInterval( 2.0 )
        self.addStep( "Dismiss suggested users/follow tutorial (if present)" )
        if self.elementExistsWithAccessibilityLabel( "Next" ) {
            self.tester().tapViewWithAccessibilityLabel( "Next" )
        }
        
        self.tester().waitForTimeInterval( 2.0 )
        self.addStep( "Skip forced content creation (if possible), otherwise add random text for first post." )
        if self.elementExistsWithAccessibilityLabel( "Skip" ) {
            self.tester().tapViewWithAccessibilityLabel( "Skip" )
        }
        else {
            let text = "\(self.generateRandomInteger()) \(self.generateRandomInteger())"
            self.tester().waitForViewWithAccessibilityLabel(VAutomationIdentifierTextPostEditableMainField).tap()
            self.tester().enterTextIntoCurrentFirstResponder( text )
            self.tester().tapViewWithAccessibilityLabel( "Done" )
            self.tester().waitForTimeInterval( 2.0 )
            self.tester().tapViewWithAccessibilityLabel( "Done" )
        }
        
        self.addStep( "Return to profile screen from settings." )
        self.tester().tapViewWithAccessibilityLabel( "Back" )
        
        self.addStep( "If registration in was successful, the profile stream should now be visible with the randomly-generated username used to sign up now visible in the UI." )
        let label = self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierProfileUsernameTitle ) as! UILabel
        XCTAssertEqual( label.text!, username )
    }
}
