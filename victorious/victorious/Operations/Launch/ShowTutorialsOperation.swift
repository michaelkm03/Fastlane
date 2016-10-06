//
//  ShowTutorialsOperation.swift
//  victorious
//
//  Created by Tian Lan on 5/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class ShowTutorialsOperation: AsyncOperation<Void> {

    fileprivate weak var originViewController: UIViewController?
    fileprivate let dependencyManager: VDependencyManager
    fileprivate let animated: Bool
    
    let lastShownVersionDefaultsKey = "com.victorious.tutorials.lastShownVersion"
    
    // Update this string to force show the tutorial again for all users that receive this update
    let newVersionWithMajorFeatures = AppVersion(versionNumber: "5.0")
    
    init(originViewController: UIViewController, dependencyManager: VDependencyManager, animated: Bool = false) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.animated = animated
    }
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(_ finish: @escaping (_ result: OperationResult<Void>) -> Void) {
        let error = NSError(domain: "ShowTutorialsOperation", code: -1, userInfo: nil)
        
        guard let currentVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            finish(.failure(error))
            return
        }
        
        let currentVersion = AppVersion(versionNumber: currentVersionString)
        
        guard shouldShowTutorials(currentVersion) else {
            finish(.success())
            return
        }
        
        guard let tutorialViewController = dependencyManager.templateValue(ofType: TutorialViewController.self, forKey: "tutorial") as? TutorialViewController else {
            finish(.failure(error))
            return
        }
        
        tutorialViewController.onContinue = {
            finish(.success())
        }
        
        let tutorialNavigationController = UINavigationController(rootViewController: tutorialViewController)
        originViewController?.present(tutorialNavigationController, animated: animated, completion: nil)
    }
    
    func shouldShowTutorials(_ currentVersion: AppVersion, userDefaults: UserDefaults = UserDefaults.standard) -> Bool {
        defer {
            // Always set the current version as the last seen
            userDefaults.setValue(currentVersion.string, forKey: lastShownVersionDefaultsKey)
        }
        
        // If the current app version does not contain major features, we don't show tutorials screen
        guard currentVersion >= newVersionWithMajorFeatures else {
            return false
        }
        
        // If this fails we have never seen a tutorial before so we should show
        guard let lastShownVersionString = userDefaults.value(forKey: lastShownVersionDefaultsKey) as? String else {
            return true
        }
        
        let lastShownVersion = AppVersion(versionNumber: lastShownVersionString)
        
        // If the last time we saw a tutorial was before this new version, show the tutorial
        return lastShownVersion < newVersionWithMajorFeatures
    }
}
