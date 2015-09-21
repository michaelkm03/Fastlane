//
//  ContentViewStreamTransition.swift
//  victorious
//
//  Created by Patrick Lynch on 9/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// A custom transition used to show `VNewContentViewController` with a "split-reveal" style animation.
class ContentViewStreamTransition : NSObject, VAnimatedTransition {
    
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
        
        guard let navController = model.toViewController as? VNavigationController,
            let contentViewController = navController.innerNavigationController?.topViewController as? VNewContentViewController,
            let snapshotImage = self.imageOfView( model.fromViewController.view ),
            let previewProvider = contentViewController.viewModel.context.contentPreviewProvider,
            let previewReceiver = contentViewController.contentCell as? VContentPreviewViewReceiver else {
                fatalError( "Missing references required for transition animation" )
        }
        
        model.fromViewController.tabBarController
        
        self.handoffController.statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        if let rootViewController = model.fromViewController as? VRootViewController,
            let scaffold = rootViewController.currentViewController as? VTabScaffoldViewController {
                self.handoffController.tabbarHeight = scaffold.tabBarController?.tabBar.frame.height ?? 0.0
        }
        
        // Mediate the handoff of views and setup of constraints
        self.handoffController.addPreviewView(
            fromProvider: previewProvider,
            toReceiver: previewReceiver,
            originSnapshotImage: snapshotImage )
        self.handoffController.previewLayout?.parent.layoutIfNeeded()
        for layout in self.handoffController.sliceLayouts {
            layout.parent.layoutIfNeeded()
        }
    }
    
    func prepareForTransitionOut(model: VTransitionModel) {
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
            options: [],
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
        
        guard let navController = model.fromViewController as? VNavigationController,
            let contentView = navController.innerNavigationController?.topViewController as? VNewContentViewController,
            let contentPreviewProvider = contentView.viewModel.context.contentPreviewProvider,
            let view = contentView.viewModel.context.contentPreviewProvider?.getPreviewView() else {
                fatalError( "Missing references required for transition animation" )
        }
        
        contentPreviewProvider.getPreviewView().focusType = .Stream
        
        UIView.animateWithDuration( model.animationDuration,
            delay: 0.0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.0,
            options: [],
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
                    layout.parent.layoutIfNeeded()
                }
            },
            completion: { finished in
                contentPreviewProvider.restorePreviewView( view )
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
