//
//  Sample.swift
//  victorious
//
//  Created by Patrick Lynch on 8/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class ContentCreationTests: VictoriousTestCase {
    
    func testCreateImage() {
        
        self.tester().tapViewWithAccessibilityLabel( "Menu Create" )
        
        // Log in if presented after pressing "Create"
        self.loginIfRequired()
        
        self.tester().tapViewWithAccessibilityLabel( "Create Image" )
        
        self.grantLibraryPermissionIfRequired()
        
        // Select image from gallery
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tester().tapItemAtIndexPath( indexPath, inCollectionViewWithAccessibilityIdentifier: VAutomationIdentifierMediaGalleryCollection )
        
        // Add a random caption
        self.tester().tapViewWithAccessibilityLabel( "Publish" )
        
        self.tester().tapViewWithAccessibilityLabel( VAutomationIdentifierPublishCatpionText )
        
        let randomCaption = "\(100000 + arc4random() % 100000)"
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
