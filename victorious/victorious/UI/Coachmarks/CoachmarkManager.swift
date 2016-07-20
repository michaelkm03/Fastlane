//
//  CoachmarkManager.swift
//  victorious
//
//  Created by Darvish Kamalia on 7/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

private struct Constants {
    static let shownCoachmarksKey = "shownCoachmarks"
    static let coachmarksArrayKey = "coachmarks"
}

@objc(VCoachmarkManager)
class CoachmarkManager : NSObject {
    let dependencyManager: VDependencyManager
    var coachmarks: [Coachmark] = []
    var allowCoachmarks = false
    
    private var trackingManager: VTrackingManager {
        return VTrackingManager.sharedInstance()
    }
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        super.init()
        reloadCoachmarks()
    }
    
    private func reloadCoachmarks() {
        guard let coachmarkConfigurations = dependencyManager.arrayForKey(Constants.coachmarksArrayKey) as? [[NSObject : AnyObject]] else {
            assertionFailure("No coachmarks could be found in coachmark manager")
            return
        }
        coachmarks = []
        let shownCoachmarks = fetchShownCoachmarkIDs()
        for coachmarkConfiguration in coachmarkConfigurations {
            let childDependency = dependencyManager.childDependencyManagerWithAddedConfiguration(coachmarkConfiguration)
            let coachmark = Coachmark(dependencyManager: childDependency)
            if (shownCoachmarks.contains(){ shownCoachmarkID in
                return shownCoachmarkID == coachmark.remoteID
            }) {
                coachmark.hasBeenShown = true
            }
            coachmarks.append(coachmark)
        }
    }

    func resetShownCoachmarks() {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: Constants.shownCoachmarksKey)
        reloadCoachmarks()
    }
    
    private func fetchShownCoachmarkIDs() -> [String] {
        return NSUserDefaults.standardUserDefaults().objectForKey(Constants.shownCoachmarksKey) as? [String] ?? []
    }
    
    private func saveCoachmarkState() {
        let shownCoachmarkIDs = coachmarks.filter { (coachmark) -> Bool in
            return coachmark.hasBeenShown
            }.map { return $0.remoteID }
        NSUserDefaults.standardUserDefaults().setObject(shownCoachmarkIDs, forKey: Constants.shownCoachmarksKey)
    }
    
    /**
     Creates the coachmark and displays it over the viewController. This performs calculations
     on view frames, hence it must be called after these have been set, for example in viewDidAppear
     
     - parameter displayer: The object that will provide the frames for the coachmark, and will handle callbacks
     - parameter container: The container frame of the coachmark, usually the entire screen
    */
    func displayCoachmark(inCoachmarkDisplayer displayer: CoachmarkDisplayer, withContainerView container: UIView) {
        guard allowCoachmarks else {
            assertionFailure("Coachmarks are not enabled")
            return
        }
        
        let screenIdentifier = displayer.screenIdentifier
        if let index = coachmarks.indexOf({ $0.screenIdentifier == screenIdentifier}) {
            let coachmarkToDisplay = coachmarks[index]
            
            var highlightFrame: CGRect? = nil
            if
                let highlightIdentifier = coachmarkToDisplay.highlightIdentifier,
                let frame = displayer.highlightFrame(highlightIdentifier)
            {
                highlightFrame = frame
            }
            
            if (!coachmarkToDisplay.hasBeenShown) {
                let containerFrame = container.bounds
                let coachmarkView = CoachmarkView(coachmark: coachmarkToDisplay, containerFrame: containerFrame, highlightFrame: highlightFrame, displayer: displayer)
                coachmarkView.alpha = 0
                container.addSubview(coachmarkView)
                
                UIView.animateWithDuration(1, animations: { 
                    coachmarkView.alpha = 1
                }) {  _ in
                    coachmarkToDisplay.hasBeenShown = true
                    self.saveCoachmarkState()
                    self.trackingManager.
                    displayer.coachmarkDidShow()
                }
            }
        }
    }
}