//
//  VictoriousTestCase.swift
//  victorious
//
//  Created by Patrick Lynch on 8/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import KIF

var shouldResetSession = false

class VictoriousTestCase: KIFTestCase {
    
    private static var shouldAppend = false
    
    private static let networkQueue = NSOperationQueue()
    
    private var ignoreExceptions: Bool = false
    private var exceptions = [NSException]()
    private var steps = [String : [String]]()
    
    override func failWithException(exception: NSException!, stopTest stop: Bool) {
        if !self.ignoreExceptions {
            super.failWithException( exception, stopTest: stop)
        }
        else {
            self.exceptions.append( exception )
        }
    }
    
    var testDescription: String {
        fatalError("All test cases must provide a detailed description.")
    }
    
    override func beforeAll() {
        super.beforeAll()
        
        let title = NSStringFromClass(self.dynamicType).pathExtension.camelCaseSeparatedString.capitalizedString
        self.addTextToReport( "\n\n# \(title)\n\(self.testDescription)\n" )
        
        // Login if forced login is presented
        self.loginIfRequired()
        self.addStep( "Logs in using email if test is run while no user is logged in." )
        
        self.dismissWelcomeIfPresent()
        self.addStep( "Dismisses the FTUE welcome screen if test is run on first install." )
    }
    
    /// Resets the session, returning the app to a state as if it has just been launched.
    /// This method is called automatically before each test is run, but it is exposed here
    /// so that tests can manually reset the session if needed.
    func resetSession() {
        if let window = UIApplication.sharedApplication().windows[0] as? UIWindow,
            let rootViewController = window.rootViewController as? VRootViewController {
                rootViewController.startNewSession()
                self.tester().waitForTimeInterval( 10.0 )
        }
    }
    
    override func beforeEach() {
        super.beforeEach()
        
        // Reset Session
        if shouldResetSession {
            self.resetSession()
        }
        
        // After the first test is run, we should reset sesssions
        shouldResetSession = true
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
    
    lazy var dateFormatter: NSDateFormatter = {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy @ HH:mm";
        return dateFormatter
    }()
    
    private func addTextToReport( var text: String ) {
        if !NSFileManager.defaultManager().fileExistsAtPath(TEST_SUMMARY_PATH) {
            return
        }
        
        if !VictoriousTestCase.shouldAppend {
            let appVersion = NSBundle.mainBundle().objectForInfoDictionaryKey( "CFBundleShortVersionString" ) as? String ?? ""
            let appBuildNumber = NSBundle.mainBundle().objectForInfoDictionaryKey( kCFBundleVersionKey as String ) as? String ?? ""
            let dateString = self.dateFormatter.stringFromDate(NSDate())
            let versionText = "v\(appVersion) (\(appBuildNumber))"
            text = "Updated: \(dateString)\n\n\(versionText)\n\(text)"
        }
        else if let existingText = String(contentsOfFile: TEST_SUMMARY_PATH, encoding: NSUTF8StringEncoding, error: nil) {
            text = existingText + "\n" + text
        }
        var error: NSError?
        if !text.writeToFile(TEST_SUMMARY_PATH, atomically: false, encoding: NSUTF8StringEncoding, error: &error) {
            println( "Failed to write to file: \(error?.localizedDescription)" )
        }
        if !VictoriousTestCase.shouldAppend {
            VictoriousTestCase.shouldAppend = true
        }
    }
    
    func addStep( text: String, function: String = __FUNCTION__ ) {
        let testTitle = function.strippedParenthesesString.camelCaseSeparatedString.capitalizedString
        if testTitle == "Before Each" || testTitle == "Before All" {
            return
        }
        if steps[ testTitle ] == nil {
            steps[ testTitle ] = [String]()
            self.addTextToReport( "\n#### \(testTitle)" )
        }
        println( ">>> \(text)" )
        self.addTextToReport( "- \(text)" )
    }
    
    func logoutIfLoggedIn( function: String = __FUNCTION__ ) {
        self.addStep( "Navigate to the settings section and log out if not already logged out.", function: function )
        self.tester().waitForViewWithAccessibilityLabel( "Menu Profile" ).tap()
        self.tester().waitForTimeInterval( 3.0 )
        self.tester().waitForViewWithAccessibilityLabel( "Accessory Menu Settings" ).tap()
        self.tester().scrollToBottomOfTableView( VAutomationIdentifierSettingsTableView )
        if self.elementExistsWithAccessibilityLabel( VAutomationIdentifierSettingsLogOut ) {
            self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierSettingsLogOut ).tap()
            self.tester().waitForTimeInterval( 3.0 )
        }
    }
}

private extension String {
    
    var camelCaseSeparatedString: String {
        if let regex = NSRegularExpression(pattern: "([a-z])([A-Z])", options: nil, error: nil) {
            return regex.stringByReplacingMatchesInString(self,
                options:nil,
                range: NSMakeRange(0, count(self)),
                withTemplate:"$1 $2")
        }
        return self
    }
    
    var strippedParenthesesString: String {
        return self.stringByReplacingOccurrencesOfString( "()", withString: "")
    }
}