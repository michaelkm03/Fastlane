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
    
    @IBAction func toggleStage() {
        stageViewControllerContainer.hidden = !stageViewControllerContainer.hidden
    }
    
    @IBAction func toggleChat() {
        chatFeedViewControllerContainer.hidden = !chatFeedViewControllerContainer.hidden
    }
    
    @IBAction func toggleComposer() {
        composerViewControllerContainer.hidden = !composerViewControllerContainer.hidden
    }
    
    private var chatFeedViewController: ChatFeedViewController!
    
    private var composerViewController: ComposerViewController!
    
    private var stageViewController: StageViewController!
    
    class func new( dependencyManager dependencyManager: VDependencyManager ) -> ForumViewController {
        let storyboard = UIStoryboard(name: "ForumViewController", bundle: nil)
        guard let forumVC = storyboard.instantiateInitialViewController() as? ForumViewController else {
            fatalError("Failed to instantiate an ForumViewController view controller!")
        }
        
        return forumVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupChildViewControllers()
    }
    
    private func setupChildViewControllers() {
        
        for childViewController in childViewControllers {
            
            if let viewController = childViewController as? ChatFeedViewController {
                chatFeedViewController = viewController
            } else if let viewController = childViewController as? ComposerViewController {
                composerViewController = viewController
            } else if let viewController = childViewController as? StageViewController {
                stageViewController = viewController
            } else {
                assertionFailure("Encountered unexpected child view controller!")
            }
        }
    }
    
}
