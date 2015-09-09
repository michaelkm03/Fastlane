//
//  Sample.swift
//  victorious
//
//  Created by Patrick Lynch on 8/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import KIF
import UIKit

class ContentCreationTests: LoggedInVictoriousTestCase {
    
    override var testDescription: String {
        return "Tests the various types of content creation available to users."
    }
    
    func testCreateImage() {
        
        self.addStep( "Select *IMAGE* from the creation menu." )
        
        // Log in if presented after pressing "Create"
        self.loginIfRequired()
        
        self.tester().tapViewWithAccessibilityLabel( "Menu Create" )
        
        // Log in if presented after pressing "Create"
        self.loginIfRequired()
        
        self.tester().tapViewWithAccessibilityLabel( "Create Image" )
        
        self.addStep( "Select the first image in the device's library." )
        
        // Select image from gallery
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tester().tapItemAtIndexPath( indexPath, inCollectionViewWithAccessibilityIdentifier: VAutomationIdentifierMediaGalleryCollection )
        
        // Add a random caption
        self.tester().tapViewWithAccessibilityLabel( "Publish" )
        
        self.tester().tapViewWithAccessibilityLabel( VAutomationIdentifierPublishCatpionText )
        
        let randomCaption = "\(100000 + arc4random_uniform(100000))"
        self.tester().enterTextIntoCurrentFirstResponder( randomCaption )
        self.addStep( "Add a random caption (e.g. \"\(randomCaption)\")" )
        
        self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierPublishFinish ).tap()
        
        self.addStep( "Wait long enough for the image to be transcoded on the backend")
        self.tester().waitWithCountdownForInterval( 20.0 )
        
        self.addStep( "Check that a post with the same random caption is available in the user's profile." )
        self.tester().waitForViewWithAccessibilityLabel( "Menu Profile" ).tap()
        
        self.tester().waitForTimeInterval( 2.0 )
        self.tester().swipeViewWithAccessibilityLabel( VAutomationIDentifierStreamCollectionView, inDirection: KIFSwipeDirection.Down )
        self.tester().waitForTimeInterval( 10.0 )
        
        let view = self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierStreamCellCaption )
        self.tester().expectView( view, toContainText: randomCaption )
    }
}
