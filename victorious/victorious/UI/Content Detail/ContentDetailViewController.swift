//
//  ContentDetailViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 9/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class ContentDetailOptions: NSObject {
    var assetPreviewView: UIView?
    var dismissalCallback:(()->())?
}

class ContentDetailViewController: UIViewController {
    
    var options: ContentDetailOptions!
    private let handoffController = ContentDetailHandoffController()
    
    private var commentsViewController: CommentsViewController!
    
    @IBOutlet weak private var contentContainer: UIView!
    @IBOutlet weak private var commentsContainer: UIView!
    @IBOutlet weak private var ballisticsContainer: UIView!
    
    private var contentOriginFrame = CGRect.zeroRect
    
    // MARK: - Factory Method
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> ContentDetailViewController {
        let commentsViewController: CommentsViewController = CommentsViewController.v_initialViewControllerFromStoryboard()
        commentsViewController.dependencyManager = dependencyManager
        
        let contentDetailViewController: ContentDetailViewController = self.v_initialViewControllerFromStoryboard( storyboardName: "ContentDetail" )
        contentDetailViewController.dependencyManager = dependencyManager
        contentDetailViewController.commentsViewController =  commentsViewController
        
        return contentDetailViewController
    }
    
    var dependencyManager: VDependencyManager?
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.commentsContainer.addSubview( self.commentsViewController.view )
        self.view.v_addFitToParentConstraintsToSubview( self.commentsViewController.view )
        
        dispatch_after(2.0) {
            self.animateOut()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if handoffController.layout == nil,
            let view = self.options.assetPreviewView,
            let constraint = self.contentContainer.v_internalHeightConstraint() {
                
                // FIXME: Don't use window
                let window = UIApplication.sharedApplication().delegate!.window!!
                self.contentOriginFrame = window.convertRect( view.frame, fromView: view )
                
                constraint.constant = self.contentOriginFrame.maxY
                self.contentContainer.layoutIfNeeded()
                
                self.handoffController.addView( view,
                    toParentView: self.contentContainer,
                    originFrame:self.contentOriginFrame )
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.animateIn()
    }
    
    func animateOut() {
        if let layout = self.handoffController.layout,
            let contentHeight = self.contentContainer.v_internalHeightConstraint() {
                UIView.animateWithDuration(0.5,
                    delay: 0.0,
                    usingSpringWithDamping: 1.0,
                    initialSpringVelocity: 1.0,
                    options: nil,
                    animations: {
                        layout.top.restore()
                        layout.width.restore()
                        layout.height.restore()
                        layout.center.restore()
                        layout.view.layoutIfNeeded()
                        
                        contentHeight.constant = self.contentOriginFrame.maxY
                        self.view.layoutIfNeeded()
                    },
                    completion: { finished in
                        self.options.dismissalCallback?()
                        self.dismissViewControllerAnimated(false, completion: nil)
                    })
        }
    }
    
    func animateIn() {
        if let layout = self.handoffController.layout,
            let contentHeight = self.contentContainer.v_internalHeightConstraint() {
                UIView.animateWithDuration(0.5,
                    delay: 0.0,
                    usingSpringWithDamping: 1.0,
                    initialSpringVelocity: 1.0,
                    options: nil,
                    animations: {
                        layout.top.constraint.constant = 0.0
                        layout.width.constraint.constant = 0.0
                        layout.height.constraint.constant = 0.0
                        layout.center.constraint.constant = 0.0
                        layout.view.layoutIfNeeded()
                        
                        contentHeight.constant = self.contentContainer.frame.width
                        self.view.layoutIfNeeded()
                    },
                    completion: nil)
        }
    }
}
