//
//  CoachmarkDisplayer.swift
//  victorious
//
//  Created by Darvish Kamalia on 7/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol CoachmarkDisplayer {
/**
     The id of the screen that conforms to this protocol.
     Under most circumstances this method should be implemented as such:
     {
        return self.dependencyManager.stringForKey(VDependencyManagerIDKey);
     }
     
*/
    var screenIdentifier: String { get }
    
/**
    Finds the frame to create a highlight around an item of interest, 
    if that item exists in the view heirarachy. This must be relative to
    the container frame passed into the coachmark manager's
    displayCoachmark method.
 
    parameter identifier The identifier of the item to highlight 
    return The frame
*/
    func highlightFrame(identifier: String) -> CGRect?
    
/**
    Called when the coachmark VC is ready for presentation
*/
    func addCoachmark(viewController: CoachmarkViewController)
}

extension CoachmarkDisplayer where Self : UIViewController {
    func addCoachmark(viewController: CoachmarkViewController) {
        self.presentViewController(viewController, animated: false, completion: nil)
    }
}
