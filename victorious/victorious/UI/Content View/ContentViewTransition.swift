//
//  ContentViewTransition.swift
//  victorious
//
//  Created by Patrick Lynch on 9/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class ContentViewTransition : NSObject, VAnimatedTransition {
    
    private let handoffController = ContentDetailHandoffController()
    
    func canPerformCustomTransitionFrom(fromViewController: UIViewController!, to toViewController: UIViewController!) -> Bool {
        return true
    }
    
    func prepareForTransitionIn(model: VTransitionModel!) {
        model.fromViewController.view.transform = CGAffineTransformMakeScale(0.8, 0.8)
        
        if let navController = model.toViewController as? VNavigationController,
            let contentView = navController.innerNavigationController?.topViewController as? VNewContentViewController,
            let view = contentView.viewModel.context.contentPreviewProvider?.getPreviewView(),
            let snapshotView = model.snapshotOfOriginView {
                let originFrame = contentView.viewModel.context.previewOriginFrame
                self.handoffController.addPreviewView(view,
                    snapshotView: snapshotView,
                    toParentView: contentView.contentCell.contentView,
                    originFrame: originFrame)
                
                (view as? VFocusable)?.setFocusType( .Detail )
        }
        self.handoffController.previewLayout?.parent.layoutIfNeeded()
        self.handoffController.bottomSliceLayout?.parent.layoutIfNeeded()
    }
    
    func prepareForTransitionOut(model: VTransitionModel!) {
        self.handoffController.previewLayout?.parent.layoutIfNeeded()
        self.handoffController.bottomSliceLayout?.parent.layoutIfNeeded()
    }
    
    func performTransitionIn(model: VTransitionModel!, completion: ((Bool) -> Void)!) {
        UIView.animateWithDuration( model.animationDuration,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.5,
            options: nil,
            animations: {
                if let previewLayout = self.handoffController.previewLayout {
                    previewLayout.top.apply()
                    previewLayout.width.apply()
                    previewLayout.height.apply()
                    previewLayout.center.apply()
                    previewLayout.parent.layoutIfNeeded()
                }
                
                if let view = self.handoffController.topImageView {
                    var frame = view.frame
                    frame.origin.y = -frame.height
                    view.frame = frame
                }
            },
            completion: { finished in
                completion(finished)
            }
        )
    }
    
    func performTransitionOut(model: VTransitionModel!, completion: ((Bool) -> Void)!) {
        
        model.fromViewController.view.transform = CGAffineTransformMakeScale(0.8, 0.8)
        
        UIView.animateWithDuration( model.animationDuration,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.5,
            options: nil,
            animations: {
                if let layout = self.handoffController.previewLayout {
                    layout.top.restore()
                    layout.width.restore()
                    layout.height.restore()
                    layout.center.restore()
                    layout.parent.layoutIfNeeded()
                }
                
                if let view = self.handoffController.topImageView {
                    var frame = view.frame
                    frame.origin.y = 0
                    view.frame = frame
                }
            },
            completion: { finished in
                if let navController = model.fromViewController as? VNavigationController,
                    let contentView = navController.innerNavigationController?.topViewController as? VNewContentViewController,
                    let contentPreviewProvider = contentView.viewModel.context.contentPreviewProvider,
                    let view = contentView.viewModel.context.contentPreviewProvider?.getPreviewView() {
                        contentPreviewProvider.restorePreviewView( view )
                }
                completion(finished)
            }
        )
    }
    
    var requiresImageViewFromOriginViewController: Bool {
        return true
    }
    
    var requiresImageViewFromWindow: Bool {
        return false
    }
    
    var transitionInDuration: NSTimeInterval {
        return 1.1
    }
    
    var transitionOutDuration: NSTimeInterval {
        return 1.1
    }
}