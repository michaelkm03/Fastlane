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
    
    private let lastShownVersionDefaultsKey = "com.victorious.tutorials.lastShownVersion"
    private let newVersionWithMajorFeatures = "5.0"
    
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
        // Grab current app version
        guard let currentAppVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String else {
            assertionFailure("the key `CFBundleShortVersionString` has changed.")
            return false
        }
        
        // If the current app version does not contain major features, we don't show tutorials screen
        guard currentAppVersion == newVersionWithMajorFeatures else {
            return false
        }
        
        let tutorialsLastShownForVersion = NSUserDefaults.standardUserDefaults().valueForKey(lastShownVersionDefaultsKey) as? String
        
        // If the current app version is different than what we saved last time, udpate it
        if (currentAppVersion != tutorialsLastShownForVersion) {
            NSUserDefaults.standardUserDefaults().setValue(currentAppVersion, forKey: lastShownVersionDefaultsKey)
        }
        
        return currentAppVersion != tutorialsLastShownForVersion
    }
}
