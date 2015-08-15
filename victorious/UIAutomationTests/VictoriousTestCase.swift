//
//  VictoriousTestCase.swift
//  victorious
//
//  Created by Patrick Lynch on 8/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import KIF

class VictoriousTestCase: KIFTestCase {
    
    private var ignoreExceptions: Bool = false
    private var exceptions = [NSException]()
    
    override func failWithException(exception: NSException!, stopTest stop: Bool) {
        if !self.ignoreExceptions {
            super.failWithException( exception, stopTest: stop)
        }
        else {
            self.exceptions.append( exception )
        }
    }
    
    /// Checks if the element with the provided label is present on screen
    ///
    /// :param: accessibilityLabel The label (or identifier) of the sought element
    func elementExistsWithAccessibilityLabel( accessibilityLabel: String ) -> Bool {
        self.ignoreExceptions = true
        self.tester().waitForViewWithAccessibilityLabel( accessibilityLabel )
        self.ignoreExceptions = false
        let output = self.exceptions.count == 0
        self.exceptions = []
        return output
    }
    
    /// Grants library permission, dismiss permission alert
    func grantLibraryPermissionIfRequired() {
        if self.elementExistsWithAccessibilityLabel( VAutomationIdentifierGrantLibraryAccess ) {
            self.tester().tapViewWithAccessibilityLabel( VAutomationIdentifierGrantLibraryAccess )
            self.tester().acknowledgeSystemAlert()
        }
    }
    
    /// Dismisses FTUE welcome screen if presented on first install.
    func dismissWelcomeIfPresent() {
        if self.elementExistsWithAccessibilityLabel( VAutomationIdentifierWelcomeDismiss ) {
            self.tester().tapViewWithAccessibilityLabel( VAutomationIdentifierWelcomeDismiss )
        }
    }
    
    /// Logs in with an existing user account
    ///
    /// :param: email An email account to use.  Default is "user@user.com"
    /// :param: ", password A ", password to use.  Default is "password"
    func loginIfRequired( email: String = "user@user.com", password: String = "password" ) {
        if self.elementExistsWithAccessibilityLabel( "Log In" ) {
            self.tester().waitForTappableViewWithAccessibilityLabel( "Log In" ).tap()
            self.tester().enterText( email, intoViewWithAccessibilityLabel: "Login Username Field" )
            self.tester().enterText( password, intoViewWithAccessibilityLabel: "Login Password Field" )
            self.tester().waitForTappableViewWithAccessibilityLabel( "Next" ).tap()
        }
    }
}