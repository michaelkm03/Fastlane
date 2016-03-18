//
//  ForumViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// A template driven .screen component that sets up, houses and mediates the interaction
/// between the Foumr's required concrete implementations and abstract dependencies.
class ForumViewController: UIViewController, Forum {
    
    @IBOutlet private weak var stageContainerHeight: NSLayoutConstraint! {
        didSet {
            stageContainerHeight.constant = 0.0
        }
    }
    
    @IBOutlet private weak var composerContainerHeight: NSLayoutConstraint!
    
    @IBOutlet private weak var gradientView: VLinearGradientView! {
        didSet {
            // TOOD: Read colors from template, add to spec
            gradientView.setColors( [UIColor.v_colorFromHexString("1a324c"), UIColor.v_colorFromHexString("151e27")] )
            gradientView.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientView.endPoint = CGPoint(x: 0.5, y: 1.0)
        }
    }
    
    // MARK: - Initialization
    
    class func newWithDependencyManager( dependencyManager: VDependencyManager ) -> ForumViewController {
        let forumVC: ForumViewController = ForumViewController.v_initialViewControllerFromStoryboard("Forum")
        forumVC.dependencyManager = dependencyManager
        return forumVC
    }
    
    // MARK: - ForumEventSender
    
    var nextSender: ForumEventSender? //< Calling code just needs to set this to get messages propagated the composer.
    
    // MARK: - Forum protocol requirements
    
    var stage: Stage?
    var composer: Composer?
    var chatFeed: ChatFeed?
    
    var dependencyManager: VDependencyManager!
    
    var originViewController: UIViewController {
        return self
    }

    func setStageHeight(value: CGFloat) {
        stageContainerHeight.constant = value
        view.layoutIfNeeded()
    }
    
    func setComposerHeight(value: CGFloat) {
        composerContainerHeight.constant = value
        view.layoutIfNeeded()
    }
    
    // MARK: - UIViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        debug_startGeneratingMessages(interval: 1.0)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Exit", comment: ""),
            style: .Plain,
            target: self,
            action: Selector("onClose")
        )
        
        self.title = dependencyManager.title
        self.view.backgroundColor = dependencyManager.backgroundColor
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        let destination = segue.destinationViewController

        if let stage = destination as? Stage {
            stage.dependencyManager = dependencyManager.stageDependency
            stage.delegate = self
            self.stage = stage
        
        } else if let chatFeed = destination as? ChatFeed {
            chatFeed.dependencyManager = dependencyManager.chatFeedDependency
            chatFeed.delegate = self
            self.chatFeed = chatFeed
        
        } else if let composer = destination as? Composer {
            composer.dependencyManager = dependencyManager.composerDependency
            composer.delegate = self
            self.composer = composer
        }
    }
    
    func onClose() {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
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
        return childDependencyForKey("chatFeed")!
    }
    
    var composerDependency: VDependencyManager {
        return childDependencyForKey("composer")!
    }
    
    var stageDependency: VDependencyManager {
        return childDependencyForKey("stage")!
    }
}
