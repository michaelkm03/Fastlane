//
//  UIScrollView+Offsets.swift
//  victorious
//
//  Created by Jarod Long on 7/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension UIScrollView {
    /// The `contentOffset` value that scrolls the content to the top.
    var topOffset: CGPoint {
        return CGPoint(x: 0.0, y: -contentInset.top)
    }
    
    /// The `contentOffset` value that scrolls the content to the bottom.
    var bottomOffset: CGPoint {
        return CGPoint(x: 0.0, y: max(contentSize.height + contentInset.bottom - bounds.height, 0.0))
    }
    
    /// Whether or not the scroll view is currently scrolled to the top, optionally with a tolerance value.
    func isScrolledToTop(withTolerance tolerance: CGFloat = 0.0) -> Bool {
        return floor(contentOffset.y) <= floor(topOffset.y) + tolerance || contentSize.height < bounds.height
    }
    
    /// Whether or not the scroll view is currently scrolled to the bottom, optionally with a tolerance value.
    func isScrolledToBottom(withTolerance tolerance: CGFloat = 0.0) -> Bool {
        return floor(contentOffset.y) >= floor(bottomOffset.y) - tolerance || contentSize.height < bounds.height
    }
    
    /// Scrolls the receiver to the top of its content.
    func scrollToTop(animated animated: Bool, completion: (() -> Void)? = nil) {
        guard !isScrolledToTop() else {
            completion?()
            return
        }
        
        scrollTo(topOffset, animated: animated)
    }
    
    /// Scrolls the receiver to the bottom of its content.
    func scrollToBottom(animated animated: Bool, completion: (() -> Void)? = nil) {
        guard !isScrolledToBottom() else {
            completion?()
            return
        }
        
        scrollTo(bottomOffset, animated: animated)
    }
    
    private func scrollTo(offset: CGPoint, animated: Bool, completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        CATransaction.setAnimationDuration(0.5)
        setContentOffset(offset, animated: animated)
        CATransaction.commit()
    }
}
