//
//  VMessageCollectionCell.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

@objc protocol SelfSizingCell: NSObjectProtocol {
    func cellSizeWithinBounds(bounds: CGRect) -> CGSize
}

class VMessageCollectionCell: UICollectionViewCell {
    
    static var suggestedReuseIdentifier = "VMessageCollectionCell"
    
    let spacing: CGFloat = 10.0
    let contentMargin = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 65)
    
    private var storyboardTextViewWidth: CGFloat!
    var alignmentDecorator: AlignmentDecorator! {
        didSet {
            alignmentDecorator.updateLayout(self)
        }
    }
    
    var dependencyManager: VDependencyManager! {
        didSet {
            textView.font = dependencyManager.messageFont
            textView.textColor = dependencyManager.textColor
            
            detailTextView.contentInset = UIEdgeInsetsZero
            detailTextView.font = dependencyManager.labelFont
            detailTextView.textColor = dependencyManager.textColor
            
            
            bubbleView.backgroundColor = dependencyManager.backgroundColor
            bubbleView.layer.cornerRadius = 5.0
            bubbleView.layer.borderColor = dependencyManager.textColor.CGColor
            bubbleView.layer.borderWidth = 1.0
            
            avatarView.layer.cornerRadius = avatarView.bounds.width * 0.5
            avatarView.backgroundColor = dependencyManager.backgroundColor
            
            backgroundColor = UIColor.clearColor()
            contentContainer.backgroundColor = UIColor.clearColor()
            messageContainer.backgroundColor = UIColor.clearColor()
            avatarContainer.backgroundColor = UIColor.clearColor()
            //mediaContainer.backgroundColor = UIColor.clearColor()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        storyboardTextViewWidth = textView.bounds.width
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        alignmentDecorator.updateLayout(self)
    }
    
    struct ViewData {
        let text: String
        let createdAt: NSDate
        let username: String
        let avatarImageURL: NSURL?
        let mediaURL: NSURL?
    }
    var viewData: ViewData! {
        didSet {
            if let mediaURL = viewData?.mediaURL {
                mediaContainer.hidden = false
                textView.hidden = true
                mediaContainer.backgroundColor = UIColor.redColor()
            } else {
                mediaContainer.hidden = true
                textView.hidden = false
                textView.text = viewData.text
                mediaContainer.backgroundColor = UIColor.clearColor() //< Remove this
            }
            
            let timeStamp = NSDateFormatter.vsdk_defaultDateFormatter().stringFromDate(viewData.createdAt)
            detailTextView.text = "\(viewData.username) (\(timeStamp))"
            avatarView.setProfileImageURL(viewData.avatarImageURL)
            
            setNeedsLayout()
        }
    }
    
    @IBOutlet private(set) weak var avatarContainer: UIView!
    @IBOutlet private(set) weak var avatarView: VDefaultProfileImageView!
    @IBOutlet private(set) weak var bubbleView: UIView!
    @IBOutlet private(set) weak var contentContainer: UIView!
    @IBOutlet private(set) weak var detailTextView: UITextView!
    @IBOutlet private(set) weak var messageContainer: UIView!
    @IBOutlet private(set) weak var mediaContainer: UIView!
    @IBOutlet private(set) weak var textView: UITextView!
    
    private var mediaAttachmentView: MediaAttachmentView?
    
    // MARK: - SelfSizingCell
    
    func cellSizeWithinBounds(bounds: CGRect) -> CGSize {
        alignmentDecorator.updateLayout(self)
        
        return CGSize(
            width: bounds.width,
            height: contentContainer.bounds.height + (contentMargin.top + contentMargin.bottom)
        )
    }
    
    func calculateContentSize() -> CGSize {
        let maxContentWidth = bounds.width - (contentMargin.left + contentMargin.right) - (avatarContainer.frame.width)
        if let mediaURL = viewData?.mediaURL {
            return CGSize(
                width: maxContentWidth,
                height: 100.0
            )
        } else {
            let availableTextViewSize = CGSize(width: maxContentWidth, height: CGFloat.max)
            let heightDrivenSize = textView.sizeThatFits( availableTextViewSize )
            return textView.sizeThatFits( heightDrivenSize )
        }
    }
}

private extension VDependencyManager {
    
    var textColor: UIColor {
        return self.colorForKey(VDependencyManagerMainTextColorKey)
    }
    
    var backgroundColor: UIColor {
        return self.colorForKey(VDependencyManagerSecondaryAccentColorKey)
    }
    
    var borderColor: UIColor {
        return self.colorForKey(VDependencyManagerLinkColorKey)
    }
    
    var messageFont: UIFont {
        return self.fontForKey(VDependencyManagerHeading3FontKey)
    }
    
    var labelFont: UIFont {
        return self.fontForKey(VDependencyManagerLabel2FontKey)
    }
}
