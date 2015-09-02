//
//  ContentDetailHandoffController.swift
//  victorious
//
//  Created by Patrick Lynch on 9/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class ContentDetailHandoffController {
    
    struct LayoutItem {
        let originValue: CGFloat
        let constraint: NSLayoutConstraint
        
        func restore() {
            self.constraint.constant = originValue
        }
    }
    
    struct Layout {
        let height: LayoutItem
        let width: LayoutItem
        let top: LayoutItem
        let center: LayoutItem
        let view: UIView
        let parent: UIView
    }
    
    private(set) var layout: Layout?
    
    func addView( view: UIView, toParentView parentView: UIView, originFrame: CGRect ) {
        
        parentView.addSubview(view)
        
        let widthConstraint = NSLayoutConstraint(item: view,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: parentView,
            attribute: .Width,
            multiplier: 1.0,
            constant: originFrame.width - parentView.frame.width )
        parentView.addConstraint( widthConstraint )
        
        let heightConstraint = NSLayoutConstraint(item: view,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: parentView,
            attribute: .Height,
            multiplier: 1.0,
            constant: originFrame.height - parentView.frame.height )
        parentView.addConstraint( heightConstraint )
        
        let topConstraint = NSLayoutConstraint(item: view,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: parentView,
            attribute: .Top,
            multiplier: 1.0,
            constant: originFrame.origin.y )
        parentView.addConstraint( topConstraint )
        
        let centerConstraint = NSLayoutConstraint(item: view,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: parentView,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: originFrame.midX - parentView.frame.midX )
        parentView.addConstraint( centerConstraint )
        
        self.layout = Layout(
            height: LayoutItem(originValue: heightConstraint.constant, constraint: heightConstraint),
            width: LayoutItem(originValue: widthConstraint.constant, constraint: widthConstraint),
            top: LayoutItem(originValue: topConstraint.constant, constraint: topConstraint),
            center: LayoutItem(originValue: centerConstraint.constant, constraint: centerConstraint),
            view: view,
            parent: parentView )
    }
}