//
//  ContentViewStreamTransition.swift
//  victorious
//
//  Created by Patrick Lynch on 9/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// A custom transition used to show `VNewContentViewController` with a "split-reveal" style animation.
class ContentViewStreamTransition: NSObject, VAnimatedTransition {
    
    private let handoffController = ContentViewHandoffController()
    private var initialPreviewViewFocusType: VFocusType?
    
    func canPerformCustomTransitionFrom(fromViewController: UIViewController?, to toViewController: UIViewController) -> Bool {
        for vc in [ fromViewController, Optional(toViewController) ] {
            if let contentViewController = (vc as? VNavigationController)?.innerNavigationController?.topViewController as? VNewContentViewController {
                return contentViewController.viewModel.context.contentPreviewProvider != nil
            }
        }
        return false
    }
    
    func prepareForTransitionIn(model: VTransitionModel) {
        
        guard let navController = model.toViewController as? VNavigationController,
            let contentViewController = navController.innerNavigationController?.topViewController as? VNewContentViewController,
            let previewProvider = contentViewController.viewModel.context.contentPreviewProvider,
            let previewReceiver = contentViewController.contentCell as? VContentPreviewViewReceiver else {
                fatalError( "Missing references required for transition animation" )
        }
        
        if let originViewController = previewProvider as? VContentViewOriginViewController {
            originViewController.prepareForScreenshot()
        }
        
        guard let snapshotImage = self.imageOfView( model.fromViewController.view ) else {
            fatalError( "Snapshot of view failed during transition animation" )
        }
        
        let navBarHeight = model.fromViewController.navigationController?.navigationBar.frame.height ?? 0.0
        let layoutGuideLength = model.fromViewController.topLayoutGuide.length
        self.handoffController.statusBarHeight = layoutGuideLength - navBarHeight
        if let rootViewController = model.fromViewController as? VRootViewController,
            let scaffold = rootViewController.currentViewController as? VTabScaffoldViewController {
                self.handoffController.tabbarHeight = scaffold.tabBarController?.tabBar.frame.height ?? 0.0
        }
        
        // Mediate the handoff of views and setup of constraints using the handoff controller
        self.handoffController.addPreviewView(
            fromProvider: previewProvider,
            toReceiver: previewReceiver,
            originSnapshotImage: snapshotImage )
        self.handoffController.previewLayout?.parent.layoutIfNeeded()
        for layout in self.handoffController.sliceLayouts {
            layout.parent.layoutIfNeeded()
        }
        
        let previewView = previewProvider.getPreviewView()
        self.initialPreviewViewFocusType = previewView.focusType
        previewView.focusType = .Detail
    }
    
    func prepareForTransitionOut(model: VTransitionModel) {
        self.handoffController.previewLayout?.parent.layoutIfNeeded()
        for layout in self.handoffController.sliceLayouts {
            layout.parent.layoutIfNeeded()
        }
        
        for view in self.handoffController.transitionSliceViews {
            view.hidden = false
        }
        
        // Restore the focus type
        if let navController = model.fromViewController as? VNavigationController,
            let contentView = navController.innerNavigationController?.topViewController as? VNewContentViewController,
            let initialPreviewViewFocusType = self.initialPreviewViewFocusType,
            let previewView = contentView.viewModel.context.contentPreviewProvider?.getPreviewView() {
                previewView.focusType = initialPreviewViewFocusType
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
            let contentPreviewProvider = contentView.viewModel.context.contentPreviewProvider else {
                fatalError( "Missing references required for transition animation" )
        }
        let previewView = contentPreviewProvider.getPreviewView()
        
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
                contentPreviewProvider.restorePreviewView( previewView )
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
        UIGraphicsBeginImageContextWithOptions( view.bounds.size, true, 0.0 )
        view.drawViewHierarchyInRect( view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? nil
    }
}
