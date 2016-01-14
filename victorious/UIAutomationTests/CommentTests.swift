//
//  CommentTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class CommentTests : VictoriousTestCase {
    
    override var testDescription: String {
        return "Tests posting a GIF comment on a post from user's profile."
    }
    
    func testGifCommentOnContentView() {
        
        self.addStep( "Selects the profile tab." )
        self.tester().waitForViewWithAccessibilityLabel( "Menu Profile" ).tap()
        
        self.addStep( "Selects the first post in the user's profile stream." )
        self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierStreamCell )
        self.tester().tapViewWithAccessibilityLabel( VAutomationIdentifierStreamCell )
        
        self.tester().waitForTimeInterval( 3.0 )
        
        self.addStep( "Taps into the comment text field, then selects GIF option from the keyboard bar." )
        self.tester().tapViewWithAccessibilityLabel( VAutomationIdentifierCommentBarTextView )
        self.tester().tapViewWithAccessibilityLabel( VAutomationIdentifierCommentBarGIFButton )
        
        // Wait for trending GIFs to load
        self.tester().waitForTimeInterval( 8.0 )
        
        // Tap first index path
        self.addStep( "Selects the first GIF from the trending GIFs search results." )
        let testIndexPath = NSIndexPath(forItem: 0, inSection: 0)
        let mediaCollectionViewIdentifier = AutomationId.MediaSearchCollection.rawValue
        self.tester().waitForCellAtIndexPath(testIndexPath, inCollectionViewWithAccessibilityIdentifier: mediaCollectionViewIdentifier)
        self.tester().tapItemAtIndexPath(testIndexPath, inCollectionViewWithAccessibilityIdentifier: mediaCollectionViewIdentifier)
        
        // Tap next button
        self.tester().tapViewWithAccessibilityLabel( "Next" )
        
        let randomCaption = "\(100000 + arc4random_uniform(100000))"
        self.addStep( "Adds a random caption to the GIF comment (e.g.\"\(randomCaption)\"" )
        self.tester().enterTextIntoCurrentFirstResponder( randomCaption )
        
        self.addStep( "Tap send button" )
        self.tester().waitForTimeInterval( 2.0 )
        self.tester().tapViewWithAccessibilityLabel( VAutomationIdentifierCommentBarSendButton )
        
        let duration: NSTimeInterval = 20.0
        self.addStep( "Wait \(duration) seconds for comment to post" )
        self.tester().waitWithCountdownForInterval( duration )

        self.addStep( "Ensure first comment cell has proper caption." )
        let commentCell = self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierContentViewCommentCell )
        self.tester().expectView( commentCell, toContainText: randomCaption )
        
        self.tester().waitForViewWithAccessibilityLabel( VAutomationIdentifierContentViewCloseButton ).tap()
    }
}
