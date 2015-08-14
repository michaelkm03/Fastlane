//
//  GifCommentTest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class GIFCommentTest : VictoriousTestCase {
    
    func testGIFCommentContentView() {
        
        self.dismissWelcomeIfPresent()
        
        // Go to profile
        self.tester().waitForViewWithAccessibilityLabel( "Menu Profile" ).tap()
        
        // Tap first cell
        self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierStreamCell )
        self.tester().tapViewWithAccessibilityLabel( VAutomationIdentifierStreamCell )
        
        // Tap comment bar and GIF button
        self.tester().tapViewWithAccessibilityLabel( VAutomationIdentifierCommentBarTextView )
        self.tester().tapViewWithAccessibilityLabel( VAutomationIdentifierCommentBarGIFButton )
        
        // Tap first index path
        let testIndexPath = NSIndexPath(forItem: 0, inSection: 0)
        let gifCollectionViewIdentifier = AutomationId.GIFSearchCollection.rawValue
        let cell = self.tester().waitForCellAtIndexPath(testIndexPath, inCollectionViewWithAccessibilityIdentifier: gifCollectionViewIdentifier)
        self.tester().tapItemAtIndexPath(testIndexPath, inCollectionViewWithAccessibilityIdentifier: gifCollectionViewIdentifier)
        
        // Tap next button
        self.tester().tapViewWithAccessibilityLabel( AutomationId.GIFSearchNext.rawValue )
        
        // Enter random caption
        let randomCaption = "\(100000 + arc4random() % 100000)"
        self.tester().enterTextIntoCurrentFirstResponder( randomCaption )
        
        // Tap send button
        self.tester().tapViewWithAccessibilityLabel( VAutomationIdentifierCommentBarSendButton )
        
        // Wait for comment to post
        self.tester().waitWithCountdownForInterval( 15.0 )

        // See if first comment cell has proper caption
        let commentCell = self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierContentViewCommentCell )
        self.tester().expectView( commentCell, toContainText: randomCaption )
    }
}
