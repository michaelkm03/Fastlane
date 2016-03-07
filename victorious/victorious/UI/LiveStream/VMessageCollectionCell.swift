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
    
    @IBOutlet private(set) weak var avatarContainer: UIView!
    @IBOutlet private(set) weak var avatarView: VDefaultProfileImageView!
    @IBOutlet private(set) weak var bubbleView: UIView!
    @IBOutlet private(set) weak var contentContainer: UIView!
    @IBOutlet private(set) weak var detailTextView: UITextView!
    @IBOutlet private(set) weak var messageContainer: UIView!
    @IBOutlet private(set) weak var mediaContainer: UIView!
    @IBOutlet private(set) weak var textView: UITextView!
    
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
            updateDependencies()
        }
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
            updateContent()
            updateDependencies()
            setNeedsLayout()
        }
    }
    
    private(set) var mediaAttachmentView: MediaAttachmentImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        storyboardTextViewWidth = textView.bounds.width
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        alignmentDecorator.updateLayout(self)
    }
    
    // MARK: - SelfSizingCell
    
    func cellSizeWithinBounds(bounds: CGRect) -> CGSize {
        alignmentDecorator.updateLayout(self)
        
        return CGSize(
            width: bounds.width,
            height: contentContainer.bounds.height + (contentMargin.top + contentMargin.bottom)
        )
    }
    
    func updateDependencies() {
        textView.font = dependencyManager.messageFont
        textView.textColor = dependencyManager.textColor
        
        detailTextView.contentInset = UIEdgeInsetsZero
        detailTextView.font = dependencyManager.labelFont
        detailTextView.textColor = dependencyManager.textColor
        
        bubbleView.backgroundColor = dependencyManager.backgroundColor
        bubbleView.layer.borderColor = dependencyManager.textColor.colorWithAlphaComponent(0.5).CGColor
        bubbleView.layer.cornerRadius = 5.0
        bubbleView.layer.borderWidth = 1.0
        
        avatarView.layer.cornerRadius = avatarView.bounds.width * 0.5
        avatarView.backgroundColor = dependencyManager.backgroundColor
        
        backgroundColor = UIColor.clearColor()
        contentContainer.backgroundColor = UIColor.clearColor()
        messageContainer.backgroundColor = UIColor.clearColor()
        avatarContainer.backgroundColor = UIColor.clearColor()
        mediaContainer.backgroundColor = UIColor.clearColor()
    }
    
    func updateContent() {
        if let mediaURL = viewData?.mediaURL {
            
            mediaAttachmentView?.removeFromSuperview()
            let newMediaAttachmentView = MediaAttachmentView.mediaViewForAttachment(.Image) as! MediaAttachmentImageView
            newMediaAttachmentView.setPreviewImageURL(mediaURL)
            mediaContainer.addSubview(newMediaAttachmentView)
            mediaAttachmentView = newMediaAttachmentView
            
            mediaContainer.hidden = false
            textView.hidden = true
            mediaContainer.backgroundColor = UIColor.redColor()
        } else {
            mediaContainer.hidden = true
            textView.hidden = false
            textView.text = viewData.text
            mediaAttachmentView?.removeFromSuperview()
            mediaAttachmentView = nil
        }
        
        let timeStamp = NSDateFormatter.vsdk_defaultDateFormatter().stringFromDate(viewData.createdAt)
        detailTextView.text = "\(viewData.username) (\(timeStamp))"
        avatarView.setProfileImageURL(viewData.avatarImageURL)
    }
    
    func calculateContentSize() -> CGSize {
        let maxContentWidth = bounds.width - (contentMargin.left + contentMargin.right) - (avatarContainer.frame.width)
        if let _ = viewData?.mediaURL {
            let mediaAspectRatio: CGFloat = 1.5
            return CGSize(
                width: maxContentWidth,
                height: maxContentWidth / mediaAspectRatio
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
        return self.colorForKey(VDependencyManagerBackgroundColorKey)
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
