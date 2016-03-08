//
//  MessageCell.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

@objc protocol SelfSizingCell: NSObjectProtocol {
    func cellSizeWithinBounds(bounds: CGRect) -> CGSize
}

protocol MessageCellDelegate: class {
    func messageCellDidSelectAvatarImage(messageCell: MessageCell)
    func messageCellDidSelectMedia(messageCell: MessageCell)
}

class MessageCell: UICollectionViewCell, VFocusable {
    
    static var suggestedReuseIdentifier = "MessageCell"
    
    @IBOutlet private(set) weak var avatarContainer: UIView!
    @IBOutlet private(set) weak var avatarView: VDefaultProfileImageView!
    @IBOutlet private(set) weak var bubbleView: UIView!
    @IBOutlet private(set) weak var contentContainer: UIView!
    @IBOutlet private(set) weak var detailTextView: UITextView!
    @IBOutlet private(set) weak var messageContainer: UIView!
    @IBOutlet private(set) weak var mediaView: MessageMediaView!
    @IBOutlet private(set) weak var textView: UITextView!
    
    let spacing: CGFloat = 10.0
    let contentMargin = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 65)
    
    private var storyboardTextViewWidth: CGFloat!
    var alignmentDecorator: MessageCellLayout! {
        didSet {
            alignmentDecorator.updateLayout(self)
        }
    }
    
    weak var delegate: MessageCellDelegate?
    
    var preloadedImage: UIImage? {
        return mediaView.preloadedImage
    }
    
    var dependencyManager: VDependencyManager! {
        didSet {
            updateDependencies()
        }
    }
    
    struct Media {
        let url: NSURL
        let width: CGFloat
        let height: CGFloat
        
        var aspectRatio: CGFloat { return width / height }
    }
    struct ViewData {
        let text: String
        let createdAt: NSDate
        let username: String
        let avatarImageURL: NSURL?
        let media: Media?
    }
    
    var viewData: ViewData! {
        didSet {
            updateContent()
            updateDependencies()
            setNeedsLayout()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        storyboardTextViewWidth = textView.bounds.width
        avatarContainer.addGestureRecognizer( UITapGestureRecognizer(target: self, action: "onAvatarTapped:") )
        mediaView.addGestureRecognizer( UITapGestureRecognizer(target: self, action: "onMediaTapped:") )
    }
    
    func onAvatarTapped(sender: AnyObject?) {
        delegate?.messageCellDidSelectAvatarImage(self)
    }
    
    func onMediaTapped(sender: AnyObject?) {
        delegate?.messageCellDidSelectMedia(self)
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
        //mediaView.backgroundColor = UIColor.clearColor()
    }
    
    func updateContent() {
        if let media = viewData?.media {
            mediaView.hidden = false
            textView.hidden = true
            mediaView.imageURL = media.url
        } else {
            mediaView.hidden = true
            textView.hidden = false
            textView.text = viewData.text
        }
        
        let timeStamp = NSDateFormatter.vsdk_defaultDateFormatter().stringFromDate(viewData.createdAt)
        detailTextView.text = "\(viewData.username) (\(timeStamp))"
        avatarView.setProfileImageURL(viewData.avatarImageURL)
    }
    
    func calculateContentSize() -> CGSize {
        let maxContentWidth = bounds.width - (contentMargin.left + contentMargin.right) - (avatarContainer.frame.width)
        if let media = viewData?.media {
            return CGSize(
                width: maxContentWidth,
                height: maxContentWidth / media.aspectRatio
            )
        } else {
            let availableTextViewSize = CGSize(width: maxContentWidth, height: CGFloat.max)
            let heightDrivenSize = textView.sizeThatFits( availableTextViewSize )
            return textView.sizeThatFits( heightDrivenSize )
        }
    }
    
    // MARK: - VFocusable
    
    var focusType: VFocusType = .None {
        didSet {
            mediaView?.focusType = focusType
        }
    }
    
    func contentArea() -> CGRect {
        return mediaView.frame
    }
}

private extension VDependencyManager {
    
    var textColor: UIColor {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
    
    var backgroundColor: UIColor {
        return colorForKey(VDependencyManagerBackgroundColorKey)
    }
    
    var borderColor: UIColor {
        return colorForKey(VDependencyManagerLinkColorKey)
    }
    
    var messageFont: UIFont {
        return fontForKey(VDependencyManagerHeading3FontKey)
    }
    
    var labelFont: UIFont {
        return fontForKey(VDependencyManagerLabel2FontKey)
    }
}
