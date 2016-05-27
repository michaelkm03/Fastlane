//
//  ShowTutorialsOperation.swift
//  victorious
//
//  Created by Tian Lan on 5/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ShowTutorialsOperation: MainQueueOperation {

    private weak var originViewController: UIViewController?
    private let dependencyManager: VDependencyManager
    private let animated: Bool
    private let lastShownVersion = "com.victorious.tutorials.lastShownVersion"
    
    init(originViewController: UIViewController, dependencyManager: VDependencyManager, animated: Bool = false) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.animated = animated
    }
    
    override func start() {
        beganExecuting()
        
        guard !self.cancelled && shouldShowTutorials else {
            finishedExecuting()
            return
        }
        
        guard let tutorialViewController = dependencyManager.templateValueOfType(TutorialViewController.self, forKey: "tutorial") as? TutorialViewController else {
            finishedExecuting()
            return
        }
        
        tutorialViewController.onContinue = { [weak self] in
            self?.finishedExecuting()
        }
        
        let tutorialNavigationController = UINavigationController(rootViewController: tutorialViewController)
        originViewController?.presentViewController(tutorialNavigationController, animated: animated, completion: nil)
    }
    
    private var shouldShowTutorials: Bool {
        guard let currentAppVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String else {
            assertionFailure("the key `CFBundleShortVersionString` has changed.")
            return false
        }
        
        let tutorialsLastShownForVersion = NSUserDefaults.standardUserDefaults().valueForKey(lastShownVersion) as? String
        
        if (currentAppVersion != tutorialsLastShownForVersion) {
            NSUserDefaults.standardUserDefaults().setValue(currentAppVersion, forKey: lastShownVersion)
        }
        
        return currentAppVersion != tutorialsLastShownForVersion
    }
}
