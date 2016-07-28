//
//  CoachmarkDisplayer.swift
//  victorious
//
//  Created by Darvish Kamalia on 7/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol CoachmarkDisplayer {
    var dependencyManager: VDependencyManager! { get }
    
    ///
    ///  The id of the screen that conforms to this protocol.
    ///  Under most circumstances this method should be implemented as such:
    ///    {
    ///      return self.dependencyManager.stringForKey(VDependencyManagerIDKey);
    ///    }
    ///
    var screenIdentifier: String { get }

    /// The view to display the coachmark, usually covers the entire screen
    var coachmarkContainerView: UIView { get }
    
    ///
    /// Finds the frame to create a highlight around an item of interest,
    /// if that item exists in the view heirarachy. This must be relative to
    /// container frame passed into the coachmark manager's
    /// displayCoachmark method.
    ///
    func highlightFrame(forIdentifier identifier: String) -> CGRect?
    
    /// Called when the coachmark VC is ready for presentation
    /// Should only be called by coachmark manager. Use triggerCoachmark 
    /// to trigger the setup of the coachmark
    func presentCoachmark(from viewController: CoachmarkViewController)
    
    /// Triggers a coachmark display
    func triggerCoachmark(withContext context: String?)
}

extension CoachmarkDisplayer where Self: UIViewController {
    func presentCoachmark(from viewController: CoachmarkViewController) {
        presentViewController(viewController, animated: true, completion:  nil)
    }
    
    var screenIdentifier: String {
        return dependencyManager.stringForKey(VDependencyManagerIDKey)
    }

     var coachmarkContainerView : UIView {
        return navigationController?.view ?? self.view
    }
    
    func triggerCoachmark(withContext context: String? = nil) {
        dependencyManager.coachmarkManager?.setupCoachmark(in: self, withContainerView: coachmarkContainerView, withContext: context)
    }
}
