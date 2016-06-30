//
//  CaptionBarPopulator.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

struct CaptionBarPopulator {
    private static func textAttributesForLabel(label: UILabel, matchingTextView textView: UITextView) -> [String : AnyObject] {
        let paragraphStyle = NSMutableParagraphStyle()
        let textInsets = textView.textContainerInset
        let leftIndent = textView.textContainer.lineFragmentPadding
        paragraphStyle.firstLineHeadIndent = leftIndent
        paragraphStyle.headIndent = leftIndent
        paragraphStyle.tailIndent = -leftIndent
        paragraphStyle.lineBreakMode = .ByTruncatingTail
        paragraphStyle.paragraphSpacingBefore = textInsets.top
        paragraphStyle.paragraphSpacing = textInsets.bottom
        paragraphStyle.alignment = .Left
        
        let font: UIFont = textView.font ?? label.font
        return [
            NSParagraphStyleAttributeName : paragraphStyle,
            NSFontAttributeName : font
        ]
    }
    
    static func populate(captionBar: CaptionBar, withUser user: UserModel, andCaption caption: String) {
        let imageURL = user.previewImageURL(ofMinimumWidth: captionBar.bounds.width) ?? NSURL()
        captionBar.avatarImageView.fadeInImageAtURL(imageURL)
        
        let captionTextView = captionBar.captionTextView
        captionTextView.text = caption
        captionTextView.hidden = true
        
        let captionLabel = captionBar.captionLabel
        captionLabel.numberOfLines = captionBar.collapsedNumberOfLines
        let attributes = textAttributesForLabel(captionLabel, matchingTextView: captionTextView)
        captionLabel.attributedText = NSAttributedString(string: caption, attributes: attributes)
        captionLabel.hidden = false
        
        let collapsedRect = captionLabel.textRectForBounds(captionTextView.bounds, limitedToNumberOfLines: captionBar.collapsedNumberOfLines)
        let canExpand = collapsedRect != captionLabel.textRectForBounds(captionTextView.bounds, limitedToNumberOfLines: 0)
        captionBar.expandButton.hidden = !canExpand
        captionBar.labelWidthConstraint.constant = collapsedRect.width + captionTextView.textContainer.lineFragmentPadding * 2
    }
    
    static func toggle(captionBar: CaptionBar, toCollapsed collapsed: Bool) -> CGFloat {
        let captionTextView = captionBar.captionTextView
        let captionLabel = captionBar.captionLabel
        
        captionLabel.numberOfLines = collapsed ? captionBar.collapsedNumberOfLines : captionBar.expandedNumberOfLines
        captionLabel.layoutIfNeeded()
        if !collapsed {
            captionTextView.scrollRectToVisible(CGRect.zero, animated: false)
        }
        var showLabel = true
        
        let maxSize = CGSize(width: captionTextView.bounds.width, height: 1000000)
        let textHeight = ceil(captionLabel.sizeThatFits(maxSize).height) + captionTextView.textContainerInset.top + captionTextView.textContainerInset.bottom
        if !collapsed {
            let contentTextHeight = ceil(captionTextView.sizeThatFits(maxSize).height)
            showLabel = contentTextHeight == textHeight
        }
        captionTextView.hidden = showLabel
        captionLabel.hidden = !showLabel
        captionTextView.scrollEnabled = !showLabel
        
        let visibleHeight = max(textHeight, captionBar.avatarImageViewHeightConstraint.constant)
        let captionLabelVerticalPadding = captionBar.verticalLabelPaddingConstraints.reduce(0, combine: { $0 + $1.constant })
        return captionLabelVerticalPadding + visibleHeight
    }
}
