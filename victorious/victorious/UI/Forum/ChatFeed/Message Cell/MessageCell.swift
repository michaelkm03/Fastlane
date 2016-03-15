//
//  MessageCell.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

@objc protocol SelfSizingCell {
    func cellSizeWithinBounds(bounds: CGRect) -> CGSize
}

protocol MessageCellDelegate: class {
    func messageCellDidSelectAvatarImage(messageCell: MessageCell)
    func messageCellDidSelectMedia(messageCell: MessageCell)
}

class MessageCell: UICollectionViewCell, VFocusable {
    
    static let suggestedReuseIdentifier = "MessageCell"
    
    @IBOutlet private(set) weak var avatarContainer: UIView!
    @IBOutlet private(set) weak var avatarView: VDefaultProfileImageView!
    @IBOutlet private(set) weak var bubbleView: UIView!
    @IBOutlet private(set) weak var contentContainer: UIView!
    @IBOutlet private(set) weak var detailTextView: UITextView!
    @IBOutlet private(set) weak var messageContainer: UIView!
    @IBOutlet private(set) weak var mediaView: MessageMediaView!
    @IBOutlet private(set) weak var textView: UITextView!
    
    let horizontalSpacing: CGFloat = 10.0
    let contentMargin = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 75)
    
    var layout: MessageCellLayout! {
        didSet {
            layout.updateLayout(self)
        }
    }
    
    weak var delegate: MessageCellDelegate?
    
    var preloadedImage: UIImage? {
        return mediaView.preloadedImage
    }
    
    var dependencyManager: VDependencyManager!
    
    struct ViewData {
        let text: String?
        let createdAt: NSDate
        let username: String
        let avatarImageURL: NSURL?
        let media: ForumMedia?
    }
    
    var viewData: ViewData! {
        didSet {
            populateData()
            updateStyle()
            layout.updateLayout(self)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarContainer.addGestureRecognizer( UITapGestureRecognizer(target: self, action: "onAvatarTapped:") )
        mediaView.addGestureRecognizer( UITapGestureRecognizer(target: self, action: "onMediaTapped:") )
    }
    
    func onAvatarTapped(sender: AnyObject?) {
        delegate?.messageCellDidSelectAvatarImage(self)
    }
    
    private func onMediaTapped(sender: AnyObject?) {
        delegate?.messageCellDidSelectMedia(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout.updateLayout(self)
    }
    
    private func updateStyle() {
        detailTextView.contentInset = UIEdgeInsetsZero
        detailTextView.font = dependencyManager.labelFont
        detailTextView.textColor = dependencyManager.messageTextColor
        
        bubbleView.backgroundColor = dependencyManager.backgroundColor
        bubbleView.layer.borderColor = dependencyManager.messageTextColor.colorWithAlphaComponent(0.5).CGColor
        bubbleView.layer.cornerRadius = 5.0
        bubbleView.layer.borderWidth = 1.0
        
        avatarView.layer.cornerRadius = avatarView.bounds.width * 0.5
        avatarView.backgroundColor = dependencyManager.backgroundColor
        
        backgroundColor = UIColor.clearColor()
        contentContainer.backgroundColor = UIColor.clearColor()
        messageContainer.backgroundColor = UIColor.clearColor()
        avatarContainer.backgroundColor = UIColor.clearColor()
        mediaView.backgroundColor = UIColor.clearColor()
    }
    
    private func populateData() {
        textView.attributedText = attributedText
        if let media = viewData?.media {
            mediaView.imageURL = media.url
        }
        let timeSince = viewData.createdAt.stringDescribingTimeIntervalSinceNow()
        detailTextView.text = "\(viewData.username) (\(timeSince))"
        avatarView.setProfileImageURL(viewData.avatarImageURL)
    }
    
    // MARK: - SelfSizingCell
    
    func cellSizeWithinBounds(bounds: CGRect) -> CGSize {
        let mediaSize = calculateMediaSizeWithinBounds(bounds)
        let textSize = calculateTextSizeWithinBounds(bounds)
        let totalHeight = contentMargin.top
            + detailTextView.frame.height
            + textSize.height
            + mediaSize.height
            + contentMargin.bottom
        return CGSize(
            width: bounds.width,
            height: max(totalHeight, avatarView.frame.maxY + contentMargin.top)
        )
    }
    
    // MARK: - Sizing
    
    private func maxContentWidthWithinBounds(bounds: CGRect) -> CGFloat {
        return bounds.width - (contentMargin.left + contentMargin.right) - (avatarContainer.frame.width) - horizontalSpacing
    }
    
    func calculateTextSizeWithinBounds(bounds: CGRect) -> CGSize {
        guard let attributedText = attributedText else {
            return CGSize.zero
        }
        let maxTextWidth = maxContentWidthWithinBounds(bounds)
        let availableSizeForWidth = CGSize(width: maxTextWidth, height: CGFloat.max)
        var size = attributedText.boundingRectWithSize(availableSizeForWidth,
            options: [ .UsesLineFragmentOrigin /* .UsesFontLeading  */],
            context: nil).size
        size.height += textView.textContainerInset.bottom + textView.textContainerInset.top
        return size
    }
    
    func calculateMediaSizeWithinBounds(bounds: CGRect) -> CGSize {
        
        guard let media = viewData?.media else {
            return CGSize.zero
        }
        let maxContentWidth = maxContentWidthWithinBounds(bounds)
        return CGSize(
            width: maxContentWidth,
            height: maxContentWidth / media.aspectRatio
        )
    }
    
    private var attributedText: NSAttributedString? {
        guard let text = viewData?.text where text != "" else {
            return nil
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = layout.textAlignment
        let attributes = [
            NSParagraphStyleAttributeName : paragraphStyle,
            NSForegroundColorAttributeName : dependencyManager.messageTextColor,
            NSFontAttributeName : dependencyManager.messageFont
        ]
        return NSAttributedString(string: text, attributes: attributes)
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
    
    var messageTextColor: UIColor {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
    
    var backgroundColor: UIColor {
        return colorForKey(VDependencyManagerLinkColorKey).colorWithAlphaComponent(0.25)
    }
    
    var borderColor: UIColor {
        return colorForKey(VDependencyManagerLinkColorKey)
    }
    
    var messageFont: UIFont {
        return fontForKey(VDependencyManagerLabel1FontKey)
    }
    
    var labelFont: UIFont {
        return fontForKey(VDependencyManagerLabel2FontKey)
    }
}
