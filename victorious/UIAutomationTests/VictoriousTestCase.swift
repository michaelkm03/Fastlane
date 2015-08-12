//
//  VictoriousTestCase.swift
//  victorious
//
//  Created by Patrick Lynch on 8/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

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
    
    func elementExistsWithAccessibilityLabel( accessibilityLabel: String ) -> Bool {
        self.ignoreExceptions = true
        self.tester().waitForViewWithAccessibilityLabel( accessibilityLabel )
        self.ignoreExceptions = false
        let output = self.exceptions.count == 0
        self.exceptions = []
        return output
    }
    
    func loginIfRequired() {
        if self.elementExistsWithAccessibilityLabel( "Log In" ) {
            println( "Login required" )
            self.tester().waitForTappableViewWithAccessibilityLabel( "Log In" ).tap()
            self.tester().enterText( "user@user.com", intoViewWithAccessibilityLabel: "Login Username Field" )
            self.tester().enterText( "password", intoViewWithAccessibilityLabel: "Login Password Field" )
            self.tester().waitForTappableViewWithAccessibilityLabel( "Next" ).tap()
        }
    }
}