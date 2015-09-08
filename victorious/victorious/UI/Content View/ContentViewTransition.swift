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
        if let navController = model.toViewController as? VNavigationController,
            let contentView = navController.innerNavigationController?.topViewController as? VNewContentViewController,
            let view = contentView.viewModel.context.assetPreviewView,
            let snapshotView = model.snapshotOfOriginView {
                let originFrame = contentView.viewModel.context.previewOriginFrame
                self.handoffController.addPreviewView(view,
                    snapshotView: snapshotView,
                    toParentView: contentView.contentCell.contentView,
                    originFrame: originFrame)
        }
        self.handoffController.previewLayout?.parent.layoutIfNeeded()
        self.handoffController.bottomSliceLayout?.parent.layoutIfNeeded()
    }
    
    func prepareForTransitionOut(model: VTransitionModel!) {}
    
    func performTransitionIn(model: VTransitionModel!, completion: ((Bool) -> Void)!) {
        UIView.animateWithDuration( model.animationDuration,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.5,
            options: nil,
            animations: {
                if let previewLayout = self.handoffController.previewLayout {
                    previewLayout.top.constraint.constant = 0.0
                    previewLayout.width.constraint.constant = 0.0
                    previewLayout.height.constraint.constant = 0.0
                    previewLayout.center.constraint.constant = 0.0
                    previewLayout.parent.layoutIfNeeded()
                }
                if let bottomSliceLayout = self.handoffController.bottomSliceLayout {
                    bottomSliceLayout.bottom.constraint.constant = 0.0
                    bottomSliceLayout.parent.layoutIfNeeded()
                }
            },
            completion: completion
        )
    }
    
    func performTransitionOut(model: VTransitionModel!, completion: ((Bool) -> Void)!) {
        
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
                
                if let bottomSliceLayout = self.handoffController.bottomSliceLayout {
                    bottomSliceLayout.bottom.restore()
                    bottomSliceLayout.parent.layoutIfNeeded()
                }
            },
            completion: { finished in
                if let navController = model.fromViewController as? VNavigationController,
                    let contentView = navController.innerNavigationController?.topViewController as? VNewContentViewController,
                    let contentPreviewProvider = contentView.viewModel.context.contentPreviewProvider,
                    let view = contentView.viewModel.context.assetPreviewView {
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
        return 0.1
    }
    
    var transitionOutDuration: NSTimeInterval {
        return 0.1
    }
}