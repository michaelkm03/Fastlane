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
    
    /**
     Creates the coachmark and displays it over the viewController. This performs calculations
     on view frames, hence it must be called after these have been set, for example in viewDidAppear
     
     parameter viewController The target view controller
 
    */
    func displayCoachmark<T : UIViewController where T : CoachmarkDisplayer>
        (inViewController viewController: T) {
        resetShownCoachmarks() //REMOVE BEFORE RELEASE
        let screenIdentifier = viewController.screenIdentifier
        if let index = coachmarks.indexOf({ $0.screenIdentifier == screenIdentifier}) {
            let coachmarkToDisplay = coachmarks[index]
            
            var highlightFrame: CGRect? = nil
            if let highlightIdentifier = coachmarkToDisplay.highlightIdentifier,
                frame = viewController.highlightFrame(highlightIdentifier) {
                highlightFrame = frame
            }
            
            if (!coachmarkToDisplay.hasBeenShown) {
                
                let containerFrame = viewController.navigationController?.view.bounds ?? viewController.view.bounds
                let coachmarkView = CoachmarkView(coachmark: coachmarkToDisplay, containerFrame: containerFrame, highlightFrame: highlightFrame)
                
                if let containerView = viewController.navigationController?.view {
                    containerView.addSubview(coachmarkView)
                }
                else {
                    viewController.view.addSubview(coachmarkView)
                }
                
                coachmarkToDisplay.hasBeenShown = true
                saveCoachmarkState()
            }
            
        }
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
    
}