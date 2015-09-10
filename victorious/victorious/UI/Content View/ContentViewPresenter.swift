//
//  ContentViewPresenter.swift
//  victorious
//
//  Created by Patrick Lynch on 9/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

@objc protocol VSequencePreviewProvider {
    func getPreviewView() -> UIView
    func restorePreviewView( previewView: UIView )
}

/// :param: sequence The sequence to display
/// :param: placeHolderImage  An image, typically the sequence's thumbnail, that can be displayed
/// in the place of content while the real thing is being loaded
/// :param: comment A comment ID to scroll to and highlight, typically used when content view
/// is being presented when the app is launched with a deep link URL.
class ContentViewContext: NSObject {
    var viewController: UIViewController?
    var dependencyManager: VDependencyManager?
    var sequence: VSequence?
    var commentId: NSNumber!
    var streamId: NSString!
    var placeholderImage: UIImage!
    var contentPreviewProvider: VSequencePreviewProvider?
    
    var previewOriginFrame: CGRect {
        // FIXME: Don't use window
        if let view = self.contentPreviewProvider?.getPreviewView() {
            let window = UIApplication.sharedApplication().delegate!.window!!
            return window.convertRect( view.frame, fromView: view )
        }
        return CGRect.zeroRect
    }
}

/// A helper presenter class that helps VStreamCollectionViewController
/// or VScaffoldViewController to present a VNewContentView
class ContentViewPresenter: NSObject {
    
    let transitionDelegate = VTransitionDelegate(transition: ContentViewTransition() )
    
    /// Presents a content view for the specified VSequence object.
    ///
    /// :param: viewController the view controller from where the presentation message was sent
    /// :param: placeHolderImage An image, typically the sequence's thumbnail, that can be displayed
    /// in the place of content while the real thing is being loaded
    /// :param: comment A comment ID to scroll to and highlight, typically used when content view
    /// is being presented when the app is launched with a deep link URL.
    func presentContentView( #context: ContentViewContext ) {
        
        if let dependencyManager = context.dependencyManager,
            let viewController = context.viewController,
            let contentViewFactory = dependencyManager.contentViewFactory(),
            let sequence = context.sequence {
            
                var reason: NSString?
                if !contentViewFactory.canDisplaySequence( sequence, localizedReason: &reason ) {
                    
                    let alertController = UIAlertController(title: nil, message: reason as String!, preferredStyle: .Alert )
                    alertController.addAction( UIAlertAction(title: NSLocalizedString( "OK", comment: "" ), style:.Default, handler: nil) )
                    viewController.presentViewController(alertController, animated:true, completion:nil)
                }
                else if let contentView = contentViewFactory.contentViewForContext( context ) {
                    if viewController.presentedViewController != nil {
                        viewController.dismissViewControllerAnimated( false, completion: nil )
                    }
                    
                    contentView.transitioningDelegate = self.transitionDelegate
                    contentView.modalPresentationStyle = .Custom
                    viewController.presentViewController(contentView, animated: true, completion: nil)
                }
        }
    }
}

