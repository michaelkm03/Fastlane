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
    static let trackingURLsKey = "tracking"
    static let trackingEventName = "Coachmark Open"
    static let animationDuration = 0.5
}

class CoachmarkManager: NSObject, UIViewControllerTransitioningDelegate {
    let dependencyManager: VDependencyManager
    var coachmarks: [Coachmark] = []
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        super.init()
        reloadCoachmarks()    
    }
    
    func reloadCoachmarks() {
        guard let coachmarkConfigurations = dependencyManager.array(forKey: Constants.coachmarksArrayKey) as? [[NSObject : AnyObject]] else {
            return
        }
        let shownCoachmarks = fetchShownCoachmarkIDs()
        coachmarks = coachmarkConfigurations.map { coachmarkConfiguration in
            let childDependency = dependencyManager.childDependencyManager(withAddedConfiguration: coachmarkConfiguration)
            // FUTURE: Remove force unwrap
            let coachmark = Coachmark(dependencyManager: childDependency!)
            if shownCoachmarks.contains(coachmark.remoteID) {
                coachmark.hasBeenShown = true
            }
            return coachmark
        }
    }

    func resetShownCoachmarks() {
        UserDefaults.standard.set(nil, forKey: Constants.shownCoachmarksKey)
        reloadCoachmarks()
    }
    
    func fetchShownCoachmarkIDs() -> [String] {
        return UserDefaults.standard.object(forKey: Constants.shownCoachmarksKey) as? [String] ?? []
    }
    
    private func saveCoachmarkState() {
        let shownCoachmarkIDs = coachmarks.filter { $0.hasBeenShown }.map { $0.remoteID }
        UserDefaults.standard.set(shownCoachmarkIDs, forKey: Constants.shownCoachmarksKey)
    }
    
    /// Creates the coachmark and displays it over the viewController. This performs calculations
    /// on view frames, hence it must be called after these have been set, for example in viewDidAppear
    ///
    /// - parameter displayer: The object that will provide the frames for the coachmark, and will handle callbacks
    /// - parameter container: The container frame of the coachmark, usually the entire screen
    /// - parameter context: The context string used to differentiate between different coachmarks on the same screen, such as profile
    func setupCoachmark(in displayer: CoachmarkDisplayer, withContainerView container: UIView, withContext viewContext: String? = nil) {
        let screenIdentifier = displayer.screenIdentifier
        if let index = coachmarks.index(where: { coachmark in
            var contextMatches = true
            if let coachmarkContext = coachmark.context {
                contextMatches = viewContext == coachmarkContext
            }
            return coachmark.screenIdentifier == screenIdentifier && contextMatches
        }) {
            let coachmarkToDisplay = coachmarks[index]
            
            guard !coachmarkToDisplay.hasBeenShown else {
                return
            }
            
            var highlightFrame: CGRect? = nil
            if
                let highlightIdentifier = coachmarkToDisplay.highlightIdentifier,
                let frame = displayer.highlightFrame(forIdentifier: highlightIdentifier)
            {
                highlightFrame = frame
            }
            
            let containerFrame = container.bounds
            let coachmarkViewController = CoachmarkViewController(coachmark: coachmarkToDisplay, containerFrame: containerFrame, highlightFrame: highlightFrame)
            coachmarkViewController.transitioningDelegate = self
            
            displayer.presentCoachmark(from: coachmarkViewController)
            coachmarkToDisplay.hasBeenShown = true
            saveCoachmarkState()
            
            if let urls = dependencyManager.array(forKey: Constants.trackingURLsKey) as? [String] {
                VTrackingManager.sharedInstance().trackEvent(Constants.trackingEventName, parameters: [ VTrackingKeyUrls : urls])
            }
    
        }
    }
    
    // MARK: - UIViewControllerTransitioningDelegate

    lazy var coachmarkPresentationController = CoachmarkPresentAnimationController()
    lazy var coachmarkDismissalController = CoachmarkDismissAnimationController()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return coachmarkPresentationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return coachmarkDismissalController
    }
}
