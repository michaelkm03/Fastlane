//
//  ForumViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ForumViewController: UIViewController, ChatFeedDelegate {

    @IBOutlet private var chatFeedViewControllerContainer: UIView!
    
    @IBOutlet private var composerViewControllerContainer: UIView!
    
    @IBOutlet private var stageViewControllerContainer: UIView!
    
    private var dependencyManager: VDependencyManager!
    
    class func newWithDependencyManager( dependencyManager: VDependencyManager ) -> ForumViewController {
        let forumVC: ForumViewController = ForumViewController.v_initialViewControllerFromStoryboard("Forum")
        forumVC.dependencyManager = dependencyManager
        return forumVC
    }
    
    // MARK: - UIViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        let destination = segue.destinationViewController
        if let stage = destination as? Stage {
            stage.dependencyManager = dependencyManager
        
        } else if let chatFeed = destination as? ChatFeed {
            chatFeed.dependencyManager = dependencyManager
            chatFeed.delegate = self
        
        } else if let composer = destination as? Composer {
            composer.dependencyManager = dependencyManager
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - ChatFeedDelegate
    
    func chatFeed(chatFeed: ChatFeed, didSelectUserWithUserID userID: Int) {
        ShowProfileOperation(originViewController: self,
            dependencyManager: dependencyManager,
            userId: userID).queue()
    }
    
    func chatFeed(chatFeed: ChatFeed, didSelectMedia media: ForumMedia, withPreloadedImage image: UIImage, fromView referenceView: UIView) {
        ShowMediaLightboxOperation(originViewController: self,
            preloadedImage: image,
            referenceView: referenceView).queue()
    }
    
    // MARK: - Actions
    
    @IBAction func onClose(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
