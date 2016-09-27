//
//  CaptionBarPopulator.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Configures and updates the expanded state of a caption bar
struct CaptionBarPopulator {
    fileprivate static let animationDuration = TimeInterval(0.2)
    
    fileprivate static func textAttributesForLabel(_ label: UILabel, matchingTextView textView: UITextView) -> [String : AnyObject] {
        // Create a paragraph style to imitate the text padding around the text view
        let paragraphStyle = NSMutableParagraphStyle()
        let textInsets = textView.v_textInsets
        paragraphStyle.v_setTextInsets(textInsets)
        paragraphStyle.lineBreakMode = .ByTruncatingTail
        paragraphStyle.alignment = .Left
        
        let font: UIFont = textView.font ?? label.font
        return [
            NSParagraphStyleAttributeName : paragraphStyle,
            NSFontAttributeName : font
        ]
    }
    
    static func populate(_ captionBar: CaptionBar, withUser user: UserModel, andCaption caption: String, completion: (() -> Void)?) {
        // Configure the avatar view
        captionBar.avatarView.user = user
        
        let captionTextView = captionBar.captionTextView
        let captionLabel = captionBar.captionLabel
        
        let animationCompletion: ((Bool) -> Void) = { _ in
            // Configure the textView
            captionTextView.text = caption
            captionTextView.hidden = true
            
            // Configure the label
            captionLabel.numberOfLines = captionBar.collapsedNumberOfLines
            let textAttributes = textAttributesForLabel(captionLabel, matchingTextView: captionTextView)
            captionLabel.attributedText = NSAttributedString(string: caption, attributes: textAttributes)
            captionLabel.hidden = false
            
            // Check if we should show the expand button
            var collapsedRect = captionLabel.textRectForBounds(captionTextView.bounds, limitedToNumberOfLines: captionBar.collapsedNumberOfLines)
            let unboundedRect = captionLabel.textRectForBounds(captionTextView.bounds, limitedToNumberOfLines: 0)
            captionBar.expandButton.hidden = collapsedRect == unboundedRect
            
            // Update constraints as needed
            let textInsets = captionTextView.v_textInsets
            collapsedRect.size = CGSize(width: collapsedRect.width + textInsets.horizontal, height: collapsedRect.height + textInsets.vertical)
            captionBar.labelWidthConstraint.constant = collapsedRect.width
            
            completion?()
            
            // Animate back
            UIView.animateWithDuration(CaptionBarPopulator.animationDuration) {
                captionTextView.alpha = 1
                captionLabel.alpha = 1
            }
        }

        // Animate to alpha 0 with 0.2 seconds
        UIView.animateWithDuration(
            CaptionBarPopulator.animationDuration,
            animations: {
                captionTextView.alpha = 0
                captionLabel.alpha = 0
            },
            completion: animationCompletion
        )
    }
    
    static func toggle(_ captionBar: CaptionBar, toCollapsed collapsed: Bool) -> CGFloat {
        let captionTextView = captionBar.captionTextView
        let captionLabel = captionBar.captionLabel
        
        // Configure label
        captionLabel.numberOfLines = collapsed ? captionBar.collapsedNumberOfLines : captionBar.expandedNumberOfLines
        captionLabel.layoutIfNeeded()
        if !collapsed {
            captionTextView.scrollRectToVisible(CGRect.zero, animated: false)
        }
        
        // Figure out whether to show the label or textView
        var showLabel = true
        let maxSize = CGSize(width: captionTextView.bounds.width, height: CGFloat.max)
        let textHeight = ceil(captionLabel.sizeThatFits(maxSize).height) + captionTextView.v_textInsets.vertical
        if !collapsed {
            let contentTextHeight = ceil(captionTextView.sizeThatFits(maxSize).height)
            showLabel = contentTextHeight == textHeight
        }
        captionTextView.hidden = showLabel
        captionLabel.hidden = !showLabel
        captionTextView.scrollEnabled = true
        
        // Determine visible height
        let visibleHeight = max(textHeight, captionBar.avatarButtonHeightConstraint.constant)
        let captionLabelVerticalPadding = captionBar.verticalLabelPaddingConstraints.reduce(0, combine: { $0 + $1.constant })
        return captionLabelVerticalPadding + visibleHeight
    }
}
