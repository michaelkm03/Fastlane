//
//  ForumViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 3/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ForumViewController: UIViewController {
    
    @IBOutlet private var chatFeedViewControllerContainer: UIView!
    
    @IBOutlet private var composerViewControllerContainer: UIView!
    
    @IBOutlet private var stageViewControllerContainer: UIView!
    
    @IBOutlet private var composerViewControllerHeightConstraint: NSLayoutConstraint!
    
    private var dependencyManager: VDependencyManager!
    
    private var stage: Stage?
    
    
    //MARK: - Initialization
    
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
        if var stageViewController = destination as? Stage {
            stage = stageViewController
            stageViewController.dependencyManager = dependencyManager
        } else if let composerViewController = destination as? ComposerViewController {
            composerViewController.dependencyManager = dependencyManager
        }
        // Uncomment the following lines once the chat feed view controller is added
        // to the project.
//        else if let chatFeedViewController = destination as? ChatFeedViewController {
//            chatFeedViewController.dependencyManager = dependencyManager
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = dependencyManager.colorForKey(VDependencyManagerAccentColorKey)
        view.addGestureRecognizer( UITapGestureRecognizer(target: self, action: "exit") )
    }
    
    func exit() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
