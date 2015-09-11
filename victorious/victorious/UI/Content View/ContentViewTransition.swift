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
    private var focusTypeBeforeTransition: VFocusType?
    
    func canPerformCustomTransitionFrom(fromViewController: UIViewController!, to toViewController: UIViewController!) -> Bool {
        return true
    }
    
    func prepareForTransitionIn(model: VTransitionModel!) {
        if let navController = model.toViewController as? VNavigationController,
            let contentView = navController.innerNavigationController?.topViewController as? VNewContentViewController,
            let snapshotImage = self.imageOfView( model.fromViewController.view ),
            let view = contentView.viewModel.context.contentPreviewProvider?.getPreviewView() {
                
                self.handoffController.addPreviewView(view,
                    snapshotImage: snapshotImage,
                    toParentView: contentView.contentCell.contentView)
                
                if let videoPreviewView = view as? VVideoPreviewView {
                    contentView.videoPlayer = videoPreviewView.videoPlayer
                }
                
                if let focusableView = view as? VFocusable {
                    focusTypeBeforeTransition = focusableView.focusType
                    focusableView.focusType = VFocusType.Detail
                }
        }
        self.handoffController.previewLayout?.parent.layoutIfNeeded()
        self.handoffController.bottomSliceLayout?.parent.layoutIfNeeded()
    }
    
    func prepareForTransitionOut(model: VTransitionModel!) {
        self.handoffController.previewLayout?.parent.layoutIfNeeded()
        self.handoffController.bottomSliceLayout?.parent.layoutIfNeeded()
        
        for view in self.handoffController.transitionSliceViews {
            view.hidden = false
        }
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
                if let bottomSliceLayout = self.handoffController.bottomSliceLayout {
                    bottomSliceLayout.bottom.apply()
                    bottomSliceLayout.parent.layoutIfNeeded()
                }
            },
            completion: { finished in
                for view in self.handoffController.transitionSliceViews {
                    view.hidden = true
                }
                completion(finished)
            }
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
                    let view = contentView.viewModel.context.contentPreviewProvider?.getPreviewView() {
                        contentPreviewProvider.restorePreviewView( view )
                }
                completion(finished)
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