//
//  ForumViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ForumViewController: UIViewController {

    @IBOutlet private var chatFeedViewControllerContainer: UIView!
    
    @IBOutlet private var composerViewControllerContainer: UIView!
    
    @IBOutlet private var stageViewControllerContainer: UIView!
    
    private var dependencyManager: VDependencyManager!
    
    class func newWithDependencyManager( dependencyManager: VDependencyManager ) -> ForumViewController {
        let storyboard = UIStoryboard(name: "ForumViewController", bundle: nil)
        guard let forumVC = storyboard.instantiateInitialViewController() as? ForumViewController else {
            fatalError("Failed to instantiate an ForumViewController view controller!")
        }
        
        forumVC.dependencyManager = dependencyManager
        return forumVC
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        let destination = segue.destinationViewController
        if let stageViewController = destination as? StageViewController {
            stageViewController.dependencyManager = dependencyManager
        
        } else if let chatFeedViewController = destination as? ChatFeedViewController {
            chatFeedViewController.dependencyManager = dependencyManager
        
        } else if let composerViewController = destination as? ComposerViewController {
            composerViewController.dependencyManager = dependencyManager
        }
    }
    
    @IBAction func onClose(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
