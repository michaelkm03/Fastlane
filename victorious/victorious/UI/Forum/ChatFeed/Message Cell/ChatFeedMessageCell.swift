//
//  ChatFeedMessageCell.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

protocol ChatFeedMessageCellDelegate: class {
    func messageCellDidSelectAvatarImage(messageCell: ChatFeedMessageCell)
    func messageCellDidSelectMedia(messageCell: ChatFeedMessageCell)
}

class ChatFeedMessageCell: UICollectionViewCell {
    static let mediaCellReuseIdentifier = "MediaChatFeedMessageCell"
    static let nonMediaCellReuseIdentifier = "NonMediaChatFeedMessageCell"
    
    let detailLabel = UILabel()
    let contentContainer = UIView()
    let messageContainer = UIView()
    let bubbleView = UIView()
    let captionLabel = UILabel()
    let avatarView = VDefaultProfileImageView()
    var mediaView: MediaContentView?
    
    var layout: ChatFeedMessageCellLayout! {
        didSet {
            setNeedsLayout()
        }
    }
    
    weak var delegate: ChatFeedMessageCellDelegate?
    
    var dependencyManager: VDependencyManager! {
        didSet {
            if dependencyManager != oldValue {
                updateStyle()
            }
        }
    }
    
    var content: ContentModel? {
        didSet {
            // Updating the content is expensive, so we try to bail if we're setting the same content as before.
            // However, chat message contents don't have IDs, so we can't do this if the ID is nil.
            if content?.id == oldValue?.id && content?.id != nil {
                return
            }
            
            populateData()
            setNeedsLayout()
        }
    }
    
    // MARK: - Configuration
    
    static let captionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    static let horizontalSpacing = CGFloat(10.0)
    static let avatarSize = CGSize(width: 41.0, height: 41.0)
    static let contentMargin = UIEdgeInsets(top: 30, left: 10, bottom: 2, right: 75)
    
    // MARK: - Initializing
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        avatarView.clipsToBounds = true
        avatarView.userInteractionEnabled = true
        avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onAvatarTapped)))
        
        bubbleView.clipsToBounds = true
        
        captionLabel.backgroundColor = .clearColor()
        captionLabel.numberOfLines = 0
        detailLabel.backgroundColor = .clearColor()
        
        contentView.addSubview(detailLabel)
        contentView.addSubview(contentContainer)
        
        contentContainer.addSubview(messageContainer)
        contentContainer.addSubview(avatarView)
        
        messageContainer.addSubview(bubbleView)
        
        bubbleView.addSubview(captionLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        content?.layout.update(for: self)
        avatarView.layer.cornerRadius = avatarView.bounds.size.v_roundCornerRadius
    }
    
    // MARK: - Gesture Recognizer Actions
    
    func onAvatarTapped(sender: AnyObject?) {
        delegate?.messageCellDidSelectAvatarImage(self)
    }
    
    func onMediaTapped(sender: AnyObject?) {
        delegate?.messageCellDidSelectMedia(self)
    }
    
    private func updateStyle() {
        detailLabel.font = dependencyManager.userLabelFont
        detailLabel.textColor = dependencyManager.userLabelColor
        
        bubbleView.backgroundColor = dependencyManager.backgroundColor
        bubbleView.layer.borderColor = dependencyManager.borderColor.CGColor
        bubbleView.layer.cornerRadius = 5.0
        bubbleView.layer.borderWidth = 0.5
        
        avatarView.layer.borderWidth = 1.0
        avatarView.layer.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.3).CGColor
        avatarView.backgroundColor = dependencyManager.backgroundColor
    }
    
    private func populateData() {
        captionLabel.attributedText = content?.attributedText(using: dependencyManager)
        
        if let content = content where content.type.hasMedia {
            let mediaView = createMediaViewIfNeeded()
            mediaView.updateContent(content)
            mediaView.hidden = false
        }
        else {
            mediaView?.hidden = true
        }
        
        detailLabel.hidden = VCurrentUser.user()?.remoteId.integerValue == content?.author.id
        
        updateTimestamp()
        
        if let imageURL = content?.author.previewImageURL(ofMinimumSize: avatarView.frame.size) {
            avatarView.setProfileImageURL(imageURL)
        }
        else {
            avatarView.image = nil
        }
    }
    
    private func createMediaViewIfNeeded() -> MediaContentView {
        if let existingMediaView = self.mediaView {
            return existingMediaView
        }
        
        let mediaView = MediaContentView(showsBackground: false)
        mediaView.clipsToBounds = true
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        mediaView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onMediaTapped)))
        bubbleView.addSubview(mediaView)
        self.mediaView = mediaView
        return mediaView
    }
    
    func updateTimestamp() {
        if let name = content?.author.name, timeStamp = content?.timeLabel {
            detailLabel.text = "\(name) (\(timeStamp))"
        }
        else {
            detailLabel.text = ""
        }
    }
    
    // MARK: - Sizing
    
    static func cellHeight(displaying content: ContentModel, inWidth width: CGFloat, dependencyManager: VDependencyManager) -> CGFloat {
        let textHeight = textSize(displaying: content, inWidth: width, dependencyManager: dependencyManager).height
        let mediaHeight = mediaSize(displaying: content, inWidth: width, dependencyManager: dependencyManager).height
        let contentHeight = max(textHeight + mediaHeight, avatarSize.height)
        return contentMargin.top + contentMargin.bottom + contentHeight
    }
    
    static func textSize(displaying content: ContentModel, inWidth width: CGFloat, dependencyManager: VDependencyManager) -> CGSize {
        guard let attributedText = content.attributedText(using: dependencyManager) else {
            return CGSize.zero
        }
        
        let maxTextWidth = width - nonContentWidth
        
        var size = attributedText.boundingRectWithSize(
            CGSize(width: maxTextWidth, height: CGFloat.max),
            options: [.UsesLineFragmentOrigin],
            context: nil
        ).size
        
        size.width += captionInsets.horizontal
        size.height += captionInsets.vertical
        return size
    }
    
    static func mediaSize(displaying content: ContentModel, inWidth width: CGFloat, dependencyManager: VDependencyManager) -> CGSize {
        guard !content.assets.isEmpty else {
            return CGSize.zero
        }
        
        let maxWidth = width - nonContentWidth
        let aspectRatio = dependencyManager.clampedAspectRatio(from: content.aspectRatio)
        
        return CGSize(
            width: maxWidth,
            height: maxWidth / aspectRatio
        )
    }
    
    private static var nonContentWidth: CGFloat {
        return contentMargin.left + contentMargin.right + avatarSize.width + horizontalSpacing
    }
}

private extension ContentModel {
    var timeLabel: String {
        return createdAt.stringDescribingTimeIntervalSinceNow(format: .concise, precision: .seconds)
    }
}

private extension VDependencyManager {
    func clampedAspectRatio(from rawAspectRatio: CGFloat) -> CGFloat {
        let defaultMinimum = 0.75
        let defaultMaximum = 4.0
        let minAspect = CGFloat(numberForKey("aspectRatio.minimum")?.floatValue ?? defaultMinimum)
        let maxAspect = CGFloat(numberForKey("aspectRatio.maximum")?.floatValue ?? defaultMaximum)
        return min(maxAspect, max(rawAspectRatio, minAspect))
    }
    
    var messageTextColor: UIColor {
        return colorForKey("color.message.text") ?? .whiteColor()
    }

    var messageFont: UIFont {
        return UIFont.boldSystemFontOfSize(16)
    }

    var backgroundColor: UIColor? {
        return colorForKey("color.message.bubble") ?? .darkGrayColor()
    }
    
    var borderColor: UIColor {
        return colorForKey("color.message.border") ?? .lightGrayColor()
    }
    
    var userLabelFont: UIFont {
        return UIFont.boldSystemFontOfSize(12)
    }
    
    var userLabelColor: UIColor {
        return colorForKey("color.username.text") ?? .whiteColor()
    }
}

private extension ContentModel {
    var layout: ChatFeedMessageCellLayout {
        return wasCreatedByCurrentUser ? RightAlignmentCellLayout() : LeftAlignmentCellLayout()
    }
    
    func attributedText(using dependencyManager: VDependencyManager) -> NSAttributedString? {
        guard let text = text where text != "" else {
            return nil
        }
        
        return NSAttributedString(string: text, attributes: [
            NSForegroundColorAttributeName: dependencyManager.messageTextColor,
            NSFontAttributeName: dependencyManager.messageFont
        ])
    }
}
