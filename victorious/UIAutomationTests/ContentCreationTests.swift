//
//  Sample.swift
//  victorious
//
//  Created by Patrick Lynch on 8/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import KIF
import UIKit

class ContentCreationTests: VictoriousTestCase {
    
    override var description: String {
        return "Tests the various types of content creation available to users."
    }
    
    func testCreateImage() {
        
        self.addDescription( "Selects IMAGE from the creation menu." )
        
        self.tester().tapViewWithAccessibilityLabel( "Menu Create" )
        
        // Log in if presented after pressing "Create"
        self.loginIfRequired()
        
        self.tester().tapViewWithAccessibilityLabel( "Create Image" )
        
        self.grantLibraryPermissionIfRequired()
        
        
        self.addDescription( "Select the first image in the device's lirbary" )
        
        // Select image from gallery
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tester().tapItemAtIndexPath( indexPath, inCollectionViewWithAccessibilityIdentifier: VAutomationIdentifierMediaGalleryCollection )
        
        // Add a random caption
        self.tester().tapViewWithAccessibilityLabel( "Publish" )
        
        self.tester().tapViewWithAccessibilityLabel( VAutomationIdentifierPublishCatpionText )
        
        let randomCaption = "\(100000 + arc4random() % 100000)"
        self.tester().enterTextIntoCurrentFirstResponder( randomCaption )
        self.addDescription( "Add a random caption (e.h. \(randomCaption)" )
        
        self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierPublishFinish ).tap()
        
        // Wait for transcaoding to complete on backend
        self.tester().waitWithCountdownForInterval( 20.0 )
        
        // Confirm that post with our caption is presentin the profile stream
        self.tester().waitForViewWithAccessibilityLabel( "Menu Profile" ).tap()
        let view = self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierStreamCellCaption )
        self.tester().expectView( view, toContainText: randomCaption )
        
        self.addDescription( "Wait long enough for the image to be transcoded on the backend and then checks that a post with the same random caption is available in the user's profile." )
    }
}
