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
            layout.updateWithCell(self)
        }
    }
    
    weak var delegate: MessageCellDelegate?
    
    var preloadedImage: UIImage? {
        return mediaView.preloadedImage
    }
    
    var dependencyManager: VDependencyManager!
    
    struct ViewData {
        let text: String?
        let timeLabel: String
        let username: String
        let avatarImageURL: NSURL?
        let media: ForumMedia?
    }
    
    var viewData: ViewData! {
        didSet {
            populateData()
            updateStyle()
            layout.updateWithCell(self)
        }
    }
    
    // MARK: - UIView
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarContainer.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(onAvatarTapped(_:))) )
        mediaView.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(onMediaTapped(_:))) )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout.updateWithCell(self)
    }
    
    // MARK: - Gesture Recognizer Actions
    
    func onAvatarTapped(sender: AnyObject?) {
        delegate?.messageCellDidSelectAvatarImage(self)
    }
    
    func onMediaTapped(sender: AnyObject?) {
        delegate?.messageCellDidSelectMedia(self)
    }
    
    private func updateStyle() {
        detailTextView.contentInset = UIEdgeInsetsZero
        detailTextView.font = dependencyManager.userLabelFont
        detailTextView.textColor = dependencyManager.userLabelColor
        
        bubbleView.backgroundColor = dependencyManager.backgroundColor
        bubbleView.layer.borderColor = dependencyManager.borderColor.CGColor
        bubbleView.layer.cornerRadius = 5.0
        bubbleView.layer.borderWidth = 0.5
        
        avatarView.layer.cornerRadius = avatarView.bounds.width * 0.5
        avatarView.layer.borderWidth = 1.0
        avatarView.layer.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.3).CGColor
        avatarView.backgroundColor = dependencyManager.backgroundColor
    }
    
    private func populateData() {
        textView.attributedText = attributedText
        if let media = viewData?.media {
            mediaView.imageURL = media.url
        }
        detailTextView.text = "\(viewData.username) (\(viewData.timeLabel))"
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
            options: [ .UsesLineFragmentOrigin ],
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
        return colorForKey("color.text")
    }
    
    var messageFont: UIFont {
        return fontForKey("font.message")
    }
    
    var backgroundColor: UIColor {
        return colorForKey("color.bubble")
    }
    
    var borderColor: UIColor {
        return colorForKey("color.border")
    }
    
    var userLabelFont: UIFont {
        return fontForKey("font.userLabel")
    }
    
    var userLabelColor: UIColor {
        return colorForKey("color.userLabel")
    }
}
