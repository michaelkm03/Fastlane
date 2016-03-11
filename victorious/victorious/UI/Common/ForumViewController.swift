//
//  ForumViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ForumViewController: UIViewController, ComposerDelegate {

    @IBOutlet private var chatFeedViewControllerContainer: UIView!
    
    @IBOutlet private var composerViewControllerContainer: UIView!
    
    @IBOutlet private var stageViewControllerContainer: UIView!
    
    private var dependencyManager: VDependencyManager!
    
    private lazy var chatFeedViewController = UIViewController()
    
    private lazy var composerViewController: ComposerViewController = {
        let composer = ComposerViewController.newWithDependencyManager(self.dependencyManager)
        composer.delegate = self
        return composer
    }()
    
    private lazy var stageViewController: StageViewController = {
        return StageViewController.new(dependencyManager: self.dependencyManager)
    }()
    
    class func new( dependencyManager dependencyManager: VDependencyManager ) -> ForumViewController {
        let storyboard = UIStoryboard(name: "ForumViewController", bundle: nil)
        guard let forumVC = storyboard.instantiateInitialViewController() as? ForumViewController else {
            fatalError("Failed to instantiate an ForumViewController view controller!")
        }
        
        forumVC.dependencyManager = dependencyManager
        return forumVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupChildViewControllers()
    }
    
    private func setupChildViewControllers() {
        
        addChildViewController(stageViewController, toView: stageViewControllerContainer)
        addChildViewController(chatFeedViewController, toView: chatFeedViewControllerContainer)
        addChildViewController(composerViewController, toView: composerViewControllerContainer)
    }
    
    private func addChildViewController(viewController: UIViewController, toView view: UIView) {
        
        let viewControllerView = viewController.view
        addChildViewController(viewController)
        view.addSubview(viewControllerView)
        view.v_addFitToParentConstraintsToSubview(viewControllerView)
        viewController.didMoveToParentViewController(self)
    }
    
    
    //MARK: - ComposerDelegate
    
    func composer(composer: Composer, didPressSendWithCaption: String) {
        
    }
    
    func composer(composer: Composer, didPressSendWithMedia: MediaAttachment, caption: String?) {
        
    }
    
    func composer(composer: Composer, didSelectAttachmentTab: ComposerAttachmentTab) {
        
    }
}
