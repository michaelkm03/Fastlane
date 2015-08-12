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
        self.tester().waitForViewWithAccessbilityIdentifier( "Menu Create" ).tap()
        
        return
        
        // Log in if presented after pressing "Create"
        self.loginIfRequired()
        
        self.tester().waitForViewWithAccessbilityIdentifier( "Create Image" ).tap()
        
        // Grant library permission and dismiss alert
        if self.elementExistsWithAccessibilityLabel( VAutomationIdentifierGrantLibraryAccess ) {
            self.tester().waitForViewWithAccessbilityIdentifier( VAutomationIdentifierGrantLibraryAccess ).tap()
            self.tester().acknowledgeSystemAlert()
        }
        
        // Select image from gallery
        self.tester().waitForViewWithAccessbilityIdentifier( VAutomationIdentifierMediaGalleryCollection )
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tester().tapItemAtIndexPath( indexPath, inCollectionViewWithAccessibilityIdentifier: VAutomationIdentifierMediaGalleryCollection )
        
        // Add a random caption
        let randomCaption = "caption \(1000 + arc4random() % 1000)"
        self.tester().waitForViewWithAccessbilityIdentifier( VAutomationIdentifierWorkspaceContinue ).tap()
        self.tester().enterText( randomCaption, intoViewWithAccessibilityIdentifier: VAutomationIdentifierPublishCatpionText )
        self.tester().waitForViewWithAccessbilityIdentifier( VAutomationIdentifierPublishFinish ).tap()
        
        // Wait for transcaoding to complete on backend
        self.tester().waitWithCountdownForInterval( 20.0 )
        
        // Confirm that post with our caption is presentin the profile stream
        self.tester().waitForTappableViewWithAccessibilityLabel( "Menu Profile" ).tap()
        let view = self.tester().waitForViewWithAccessbilityIdentifier( VAutomationIdentifierStreamCellCaption )
        self.tester().expectView( view, toContainText: randomCaption )
    }
}
