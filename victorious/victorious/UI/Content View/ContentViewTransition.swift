//
//  ContentViewTransition.swift
//  victorious
//
//  Created by Patrick Lynch on 9/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// A custom transition used to show `VNewContentViewController` with a "split-to-reveal"
/// style animation.
class ContentViewTransition : NSObject, VAnimatedTransition {
    
    private let handoffController = ContentViewHandoffController()
    
    func canPerformCustomTransitionFrom(fromViewController: UIViewController?, to toViewController: UIViewController) -> Bool {
        for vc in [ fromViewController, Optional(toViewController) ] {
            if let contentViewController = (vc as? VNavigationController)?.innerNavigationController?.topViewController as? VNewContentViewController {
                return contentViewController.viewModel.context.contentPreviewProvider?.getPreviewView() != nil
            }
        }
        return false
    }
    
    func prepareForTransitionIn(model: VTransitionModel) {
        if let navController = model.toViewController as? VNavigationController,
            let contentViewController = navController.innerNavigationController?.topViewController as? VNewContentViewController,
            let snapshotImage = self.imageOfView( model.fromViewController.view ),
            let contentPreviewProvider = contentViewController.viewModel.context.contentPreviewProvider {
                
                self.handoffController.addPreviewView( contentPreviewProvider,
                    toContentViewController: contentViewController,
                    originSnapshotImage: snapshotImage )
                
                if let focusableView = contentPreviewProvider.getPreviewView() as? VFocusable {
                    focusableView.focusType = VFocusType.Detail
                }
        }
        self.handoffController.previewLayout?.parent.layoutIfNeeded()
        for layout in self.handoffController.sliceLayouts {
            layout.parent.layoutIfNeeded()
        }
    }
    
    func prepareForTransitionOut(model: VTransitionModel) {
        
        if let navController = model.fromViewController as? VNavigationController,
            let contentViewController = navController.innerNavigationController?.topViewController as? VNewContentViewController,
            let contentPreviewProvider = contentViewController.viewModel.context.contentPreviewProvider,
            let focusableView = contentPreviewProvider.getPreviewView() as? VFocusable {
                focusableView.focusType = VFocusType.Stream
        }
        
        self.handoffController.previewLayout?.parent.layoutIfNeeded()
        for layout in self.handoffController.sliceLayouts {
            layout.parent.layoutIfNeeded()
        }
        
        for view in self.handoffController.transitionSliceViews {
            view.hidden = false
        }
    }
    
    func performTransitionIn(model: VTransitionModel, completion: ((Bool) -> Void)?) {
        UIView.animateWithDuration( model.animationDuration,
            delay: 0.0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.0,
            options: nil,
            animations: {
                if let previewLayout = self.handoffController.previewLayout {
                    previewLayout.top.apply()
                    previewLayout.width.apply()
                    previewLayout.height.apply()
                    previewLayout.center.apply()
                    previewLayout.parent.layoutIfNeeded()
                }
                for layout in self.handoffController.sliceLayouts {
                    layout.constraint.apply()
                    layout.parent.layoutIfNeeded()
                }
            },
            completion: { finished in
                for view in self.handoffController.transitionSliceViews {
                    view.hidden = true
                }
                completion?(finished)
            }
        )
    }
    
    func performTransitionOut(model: VTransitionModel, completion: ((Bool) -> Void)?) {
        
        UIView.animateWithDuration( model.animationDuration,
            delay: 0.0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.2,
            options: nil,
            animations: {
                if let layout = self.handoffController.previewLayout {
                    layout.top.restore()
                    layout.width.restore()
                    layout.height.restore()
                    layout.center.restore()
                    layout.parent.layoutIfNeeded()
                }
                
                for layout in self.handoffController.sliceLayouts {
                    layout.constraint.restore()
                }
            },
            completion: { finished in
                if let navController = model.fromViewController as? VNavigationController,
                    let contentView = navController.innerNavigationController?.topViewController as? VNewContentViewController,
                    let contentPreviewProvider = contentView.viewModel.context.contentPreviewProvider,
                    let view = contentView.viewModel.context.contentPreviewProvider?.getPreviewView() {
                        contentPreviewProvider.restorePreviewView( view )
                }
                completion?(finished)
            }
        )
    }
    
    var requiresImageViewFromOriginViewController: Bool {
        return false
    }
    
    var requiresImageViewFromWindow: Bool {
        return false
    }
    
    var transitionInDuration: NSTimeInterval {
        return 0.5
    }
    
    var transitionOutDuration: NSTimeInterval {
        return 0.5
    }
    
    private func imageOfView( view: UIView ) -> UIImage? {
        UIGraphicsBeginImageContext( view.bounds.size )
        view.drawViewHierarchyInRect( view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? nil
    }
}
