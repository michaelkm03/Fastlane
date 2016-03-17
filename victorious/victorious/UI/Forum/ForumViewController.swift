//
//  ForumViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ForumViewController: UIViewController, Forum {

    @IBOutlet private weak var chatFeedContainer: UIView!
    @IBOutlet private weak var composerContainer: UIView!
    @IBOutlet private weak var stageContainer: UIView!
    
    var stage: Stage?
    var composer: Composer?
    var chatFeed: ChatFeed?
    
    // MARK: - Forum
    
    var dependencyManager: VDependencyManager!
    
    var originViewController: UIViewController {
        return self
    }
    
    // MARK: - Initialization
    
    class func newWithDependencyManager( dependencyManager: VDependencyManager ) -> ForumViewController {
        let forumVC: ForumViewController = ForumViewController.v_initialViewControllerFromStoryboard("Forum")
        forumVC.dependencyManager = dependencyManager
        return forumVC
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = dependencyManager.title
        self.view.backgroundColor = dependencyManager.backgroundColor
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        let destination = segue.destinationViewController

        if let stage = destination as? Stage {
            stage.dependencyManager = dependencyManager
            stage.delegate = self
            self.stage = stage
        
        } else if let chatFeed = destination as? ChatFeed {
            chatFeed.dependencyManager = dependencyManager.chatFeedDependency
            chatFeed.delegate = self
            self.chatFeed = chatFeed
        
        } else if let composer = destination as? Composer {
            composer.dependencyManager = dependencyManager
            composer.delegate = self
            self.composer = composer
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onClose(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - ComposerDelegate
    
    func composer(composer: Composer, didUpdateToContentHeight height: CGFloat) {
        chatFeed?.setEdgeInsets(UIEdgeInsets(top: stage?.contentHeight ?? 0, left: 0, bottom: height, right: 0))
        composerContainer.v_internalHeightConstraint()!.constant = height
    }
}

private extension VDependencyManager {
    
    var title: String {
        return stringForKey("title")
    }
    
    var backgroundColor: UIColor? {
        let background = templateValueOfType( VSolidColorBackground.self, forKey: "background") as? VSolidColorBackground
        return background?.backgroundColor
    }
    
    var chatFeedDependency: VDependencyManager {
        let configuration = templateValueOfType(NSDictionary.self, forKey: "chatFeed") as! [NSObject: AnyObject]
        return self.childDependencyManagerWithAddedConfiguration(configuration)
    }
    
    var composerDependency: VDependencyManager {
        let configuration = templateValueOfType(NSDictionary.self, forKey: "composer") as! [NSObject: AnyObject]
        return self.childDependencyManagerWithAddedConfiguration(configuration)
    }
}
