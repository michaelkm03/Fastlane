//
//  Sample.swift
//  victorious
//
//  Created by Patrick Lynch on 8/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class ContentCreationTests: VictoriousTestCase {
    
    override func beforeAll() {
        super.beforeAll()
        
        // Log in if force login is active
        self.loginIfRequired()
    }
    
    func testCreateImage() {
        self.tester().tapViewWithAccessibilityLabel( "Menu Create" )
        
        // Log in if presented after pressing "Create"
        self.loginIfRequired()
        
        self.tester().tapViewWithAccessibilityLabel( "Create Image" )
        
        // Grant library permission and dismiss alert
        if self.elementExistsWithAccessibilityLabel( VAutomationIdentifierGrantLibraryAccess ) {
            self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierGrantLibraryAccess ).tap()
            self.tester().acknowledgeSystemAlert()
        }
        
        // Select image from gallery
        self.tester().waitForTimeInterval( 2.0 )
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tester().tapItemAtIndexPath( indexPath, inCollectionViewWithAccessibilityIdentifier: VAutomationIdentifierMediaGalleryCollection )
        
        // Add a random caption
        let continueLabel = "Publish"
        self.tester().tapViewWithAccessibilityLabel( continueLabel )
        
        self.tester().waitForTimeInterval( 10.0 )
        
        self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierPublishCatpionText )
        self.tester().tapViewWithAccessibilityLabel( VAutomationIdentifierPublishCatpionText )
        
        let randomCaption = "caption \(1000 + arc4random() % 1000)"
        self.tester().enterTextIntoCurrentFirstResponder( randomCaption )
        
        self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierPublishFinish ).tap()
        
        // Wait for transcaoding to complete on backend
        self.tester().waitWithCountdownForInterval( 20.0 )
        
        // Confirm that post with our caption is presentin the profile stream
        self.tester().waitForViewWithAccessibilityLabel( "Menu Profile" ).tap()
        let view = self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierStreamCellCaption )
        self.tester().expectView( view, toContainText: randomCaption )
    }
}
