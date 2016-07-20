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
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        super.init()
        reloadCoachmarks()
    }
    
    private func reloadCoachmarks() {
        guard let coachmarkDependencies = dependencyManager.arrayForKey(Constants.coachmarksArrayKey) as? [[NSObject : AnyObject]] else {
            assertionFailure("No coachmarks could be found in coachmark manager")
            return
        }
        coachmarks = []
        let shownCoachmarks = fetchShownCoachmarkIDs()
        for coachmarkDependency in coachmarkDependencies {
            let childDependency = dependencyManager.childDependencyManagerWithAddedConfiguration(coachmarkDependency)
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
     
     parameter viewController The target view controller
 
    */
    func displayCoachmark(inCoachmarkDisplayer displayer: CoachmarkDisplayer, withContainerView container: UIView) {
        guard allowCoachmarks else {
            assertionFailure("Coachmarks are not enabled")
            return
        }
        
        resetShownCoachmarks() //REMOVE BEFORE RELEASE
        let screenIdentifier = displayer.screenIdentifier
        if let index = coachmarks.indexOf({ $0.screenIdentifier == screenIdentifier}) {
            let coachmarkToDisplay = coachmarks[index]
            
            var highlightFrame: CGRect? = nil
            if let highlightIdentifier = coachmarkToDisplay.highlightIdentifier,
                frame = displayer.highlightFrame(highlightIdentifier) {
                highlightFrame = frame
            }
            
            if (!coachmarkToDisplay.hasBeenShown) {
                
                let containerFrame = container.bounds
                let coachmarkView = CoachmarkView(coachmark: coachmarkToDisplay, containerFrame: containerFrame, highlightFrame: highlightFrame, displayer: displayer)
                coachmarkView.alpha = 0
                container.addSubview(coachmarkView)
                
                UIView.animateWithDuration(1, animations: { 
                    coachmarkView.alpha = 1
                }) { _ in
                    displayer.coachmarkDidShow()
                }
                
                coachmarkToDisplay.hasBeenShown = true
                saveCoachmarkState()
            }
            
        }
    }
}