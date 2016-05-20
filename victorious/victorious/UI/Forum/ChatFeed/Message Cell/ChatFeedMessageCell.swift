//
//  ChatFeedMessageCell.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

protocol ChatCellType {
    func cellSizeWithinBounds(bounds: CGRect) -> CGSize
    var cellContent: DisplayableChatMessage? { get set }
}

protocol ChatFeedMessageCellDelegate: class {
    func messageCellDidSelectAvatarImage(messageCell: ChatFeedMessageCell)
    func messageCellDidSelectMedia(messageCell: ChatFeedMessageCell)
}

class ChatFeedMessageCell: UICollectionViewCell, VFocusable, ChatCellType {
    
    static let suggestedReuseIdentifier = "ChatFeedMessageCell"
    
    @IBOutlet private(set) weak var avatarContainer: UIView!
    @IBOutlet private(set) weak var avatarView: VDefaultProfileImageView!
    @IBOutlet private(set) weak var bubbleView: UIView!
    @IBOutlet private(set) weak var contentContainer: UIView!
    @IBOutlet private(set) weak var detailTextView: UITextView!
    @IBOutlet private(set) weak var messageContainer: UIView!
    @IBOutlet private(set) weak var mediaView: ChatFeedMessageMediaView!
    @IBOutlet private(set) weak var textView: UITextView!
    
    let horizontalSpacing: CGFloat = 10.0
    let contentMargin = UIEdgeInsets(top: 30, left: 10, bottom: 2, right: 75)
    
    var layout: ChatFeedMessageCellLayout! {
        didSet {
            layout.updateWithCell(self)
        }
    }
    
    weak var delegate: ChatFeedMessageCellDelegate?
    
    var preloadedImage: UIImage? {
        return mediaView.preloadedImage
    }
    
    var dependencyManager: VDependencyManager!
    
    var cellContent: DisplayableChatMessage? {
        didSet {
            populateData()
            updateStyle()
            layout.updateWithCell(self)
        }
    }
    
    // MARK: - UIView
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarContainer.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(onAvatarTapped(_: ))) )
        mediaView.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(onMediaTapped(_: ))) )
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
        detailTextView.textAlignment = layout.textAlignment
        
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
        if let mediaAttachment = cellContent?.mediaAttachment {
            if mediaAttachment.type == .GIF || mediaAttachment.type == .Video {
                mediaView.previewURL = mediaAttachment.thumbnailURL
                mediaView.mediaURL = mediaAttachment.url
            } else if mediaAttachment.type == .Image {
                mediaView.previewURL = mediaAttachment.url
                mediaView.mediaURL = nil
            }
            mediaView.hidden = false
        } else {
            mediaView.hidden = true
        }
        
        if let name = cellContent?.username, timeStamp = cellContent?.timeLabel {
            detailTextView.text = "\(name) (\(timeStamp))"
        }
        
        avatarView.setProfileImageURL(cellContent?.profileURL)
    }
    
    // MARK: - ChatCellType
    
    func cellSizeWithinBounds(bounds: CGRect) -> CGSize {
        let mediaSize = calculateMediaSizeWithinBounds(bounds)
        let textSize = calculateTextSizeWithinBounds(bounds)
        let totalHeight = detailTextView.frame.height
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
        
        size.width += contentMargin.left //< Eh, this isn't quite right, thought it looks okay fr now
        return size
    }
    
    func calculateMediaSizeWithinBounds(bounds: CGRect) -> CGSize {
        guard let mediaAttachment = cellContent?.mediaAttachment else {
            return CGSize.zero
        }
        let maxContentWidth = maxContentWidthWithinBounds(bounds) + contentMargin.left
        let aspectRatio = dependencyManager.clampedAspectRatio(from: mediaAttachment.aspectRatio)
        return CGSize(
            width: maxContentWidth,
            height: maxContentWidth / aspectRatio
        )
    }
    
    private var attributedText: NSAttributedString? {
        guard let text = cellContent?.text where text != "" else {
            return nil
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = layout.textAlignment
        let attributes = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSForegroundColorAttributeName: dependencyManager.messageTextColor,
            NSFontAttributeName: dependencyManager.messageFont
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
    
    func clampedAspectRatio(from rawAspectRatio: CGFloat) -> CGFloat {
        let defaultMinimum = 1.0
        let defaultMaximum = 4.0
        let minAspect = CGFloat(numberForKey("aspectRatio.minimum")?.floatValue ?? defaultMinimum)
        let maxAspect = CGFloat(numberForKey("aspectRatio.maximum")?.floatValue ?? defaultMaximum)
        return min( maxAspect, max(rawAspectRatio, minAspect) )
    }
    
    var messageTextColor: UIColor {
        return colorForKey("color.message.text")
    }

    var messageFont: UIFont {
        return UIFont.boldSystemFontOfSize(16)
    }

    var backgroundColor: UIColor {
        return colorForKey("color.message.bubble")
    }
    
    var borderColor: UIColor {
        return colorForKey("color.message.border")
    }
    
    var userLabelFont: UIFont {
        return UIFont.boldSystemFontOfSize(12)
    }
    
    var userLabelColor: UIColor {
        return colorForKey("color.username.text")
    }
}
