//
//  ContentViewPresenter.swift
//  victorious
//
//  Created by Patrick Lynch on 9/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// - parameter sequence: The sequence to display
/// - parameter placeHolderImage: An image, typically the sequence's thumbnail, that can be displayed
/// in the place of content while the real thing is being loaded
/// - parameter comment: A comment ID to scroll to and highlight, typically used when content view is
/// being presented when the app is launched with a deep link URL.

class ContentViewContext: NSObject {
    var viewController: UIViewController?
    var originDependencyManager: VDependencyManager?
    var destinationDependencyManager: VDependencyManager?
    var sequence: VSequence?
    var commentId: NSNumber?
    var streamId: NSString?
    var placeholderImage: UIImage?
    var contentPreviewProvider: VContentPreviewViewProvider?
}

/// A helper presenter class that helps VStreamCollectionViewController
/// or VScaffoldViewController to present a VNewContentView
class ContentViewPresenter: NSObject {
    let transitionDelegate = VTransitionDelegate(transition: ContentViewStreamTransition() )
    
    /// Presents a content view for the specified VSequence object.
    ///
    /// - parameter viewController: the view controller from where the presentation message was sent
    /// - parameter placeHolderImage: An image, typically the sequence's thumbnail, that can be displayed in the
    /// place of content while the real thing is being loaded
    /// - parameter comment: A comment ID to scroll to and highlight, typically used when content view is
    /// being presented when the app is launched with a deep link URL.
    
    func presentContentView( context context: ContentViewContext ) {
        
        if let originDependencyManager = context.originDependencyManager,
            let viewController = context.viewController,
            let contentViewFactory: VContentViewFactory = originDependencyManager.contentViewFactory(),
            let sequence = context.sequence {
                
                context.destinationDependencyManager = originDependencyManager.contentViewDependencyManager()
            
                var reason: NSString?
                if !contentViewFactory.canDisplaySequence( sequence, localizedReason: &reason ) {
                    viewController.v_showErrorWithTitle(nil, message: reason as? String)
                }
                else if let contentViewController = contentViewFactory.contentViewForContext( context ) {
                    if viewController.presentedViewController != nil {
                        viewController.dismissViewControllerAnimated( false, completion: nil )
                    }
                    if context.contentPreviewProvider != nil {
                        contentViewController.transitioningDelegate = transitionDelegate;
                    }
                    viewController.presentViewController( contentViewController, animated: true, completion: nil )
                }
        }
    }
}
