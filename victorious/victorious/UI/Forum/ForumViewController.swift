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
class ForumViewController: UIViewController, Forum, VBackgroundContainer {
    
    @IBOutlet private weak var stageContainer: UIView! {
        didSet {
            stageContainer.layer.shadowColor = UIColor.blackColor().CGColor
            stageContainer.layer.shadowRadius = 8.0
            stageContainer.layer.shadowOpacity = 0.75
            stageContainer.layer.shadowOffset = CGSize(width:0, height:2)
        }
    }
    
    @IBOutlet private weak var stageContainerHeight: NSLayoutConstraint! {
        didSet {
            stageContainerHeight.constant = 0.0
        }
    }
    
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
    
    var nextSender: ForumEventSender? //< Calling code just needs to set this to get messages propagated from composer.
    
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
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return view
    }
    
    // MARK: - UIViewController overrides
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //Remove this once the way to animate the workspace in and out from forum has been figured out
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        debug_startGeneratingMessages(interval: 3.0)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Exit", comment: ""),
            style: .Plain,
            target: self,
            action: Selector("onClose")
        )
        
        updateStyle()
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
    
    // MARK: - Actions
    
    func onClose() {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func updateStyle() {
        guard isViewLoaded() else {
            return
        }
        
        title = dependencyManager.title
        view.backgroundColor = dependencyManager.backgroundColor
        let attributes = [ NSForegroundColorAttributeName : UIColor.whiteColor() ]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.tintColor = dependencyManager.navigationItemColor
        navigationController?.navigationBar.barTintColor = dependencyManager.navigationBarBackgroundColor
        navigationController?.navigationBar.translucent = false
        dependencyManager.addBackgroundToBackgroundHost(self)
    }
}

private extension VDependencyManager {
    
    var title: String {
        return stringForKey("title")
    }
    
    var navigationItemColor: UIColor {
        return colorForKey("color.navigationItem")
    }
    
    var backgroundColor: UIColor? {
        let background = templateValueOfType( VSolidColorBackground.self, forKey: "background") as? VSolidColorBackground
        return background?.backgroundColor
    }
    
    var navigationBarBackgroundColor: UIColor? {
        let background = templateValueOfType( VSolidColorBackground.self, forKey: "background.topBar") as? VSolidColorBackground
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
