//
//  ForumViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ForumViewController: UIViewController, ChatFeedDelegate, ComposerDelegate, StageDelegate {

    @IBOutlet private weak var chatFeedContainer: UIView!
    @IBOutlet private weak var composerContainer: UIView!
    @IBOutlet private weak var stageContainer: UIView!
    
    @IBOutlet private var chatFeedViewControllerContainer: UIView!
    
    @IBOutlet private var composerViewControllerContainer: UIView!
    
    @IBOutlet private var stageViewControllerContainer: UIView!
    
    @IBOutlet private var composerViewControllerHeightConstraint: NSLayoutConstraint!
    
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
            stage.delegate = self
        
        } else if let chatFeed = destination as? ChatFeed {
            chatFeed.dependencyManager = dependencyManager
            chatFeed.delegate = self
        
        } else if let composer = destination as? Composer {
            composer.dependencyManager = dependencyManager
            composer.delegate = self
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
    
    // MARK: - ComposerDelegate
    
    func composer(composer: Composer, didSelectAttachmentTab: ComposerAttachmentTab) {}
    
    func composer(composer: Composer, didPressSendWithMedia: MediaAttachment, caption: String?) {}
    
    func composer(composer: Composer, didPressSendWithCaption: String) {}
    
    func composer(composer: Composer, didUpdateToHeight: CGFloat) {}
    
    
    // MARK: - StageDelegate
    
    func stage(stage: Stage, didUpdateWithMedia media: ForumMedia) {}
    
    func stage(stage: Stage, didSelectMedia media: ForumMedia) {}
}
