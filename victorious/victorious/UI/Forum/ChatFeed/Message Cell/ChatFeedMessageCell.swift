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
    static let imagePreviewCellReuseIdentifier = "ImagePreviewChatFeedMessageCell"
    static let videoPreviewCellReuseIdentifier = "VideoPreviewChatFeedMessageCell"
    static let nonMediaCellReuseIdentifier = "NonMediaChatFeedMessageCell"
    
    let usernameLabel = UILabel()
    let timestampLabel = UILabel()
    let bubbleView = UIView()
    let bubbleBorderView = UIImageView()
    let captionLabel = UILabel()
    let avatarView = VDefaultProfileImageView()
    var previewView: UIView?
    let avatarTapTarget = UIView()
    
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
    static let bubbleBackgroundInsets = UIEdgeInsets(top: -1.0, left: -2.0, bottom: -3.0, right: -2.0)
    static let horizontalSpacing = CGFloat(10.0)
    static let avatarSize = CGSize(width: 30.0, height: 30.0)
    static let avatarTapTargetSize = CGSize(width: 44.0, height: 44.0)
    static let contentMargin = UIEdgeInsets(top: 30, left: 10, bottom: 2, right: 75)
    static let topLabelYSpacing = CGFloat(6.5)
    static let topLabelXInset = CGFloat(5.0)
    
    // MARK: - Initializing
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        avatarView.clipsToBounds = true
        avatarView.userInteractionEnabled = true
        
        avatarTapTarget.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onAvatarTapped)))
        
        bubbleBorderView.image = UIImage(named: "chat-cell-border")
        bubbleView.clipsToBounds = true
        
        captionLabel.numberOfLines = 0
        
        contentView.addSubview(usernameLabel)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(avatarView)
        contentView.addSubview(avatarTapTarget)
        contentView.addSubview(bubbleBorderView)
        contentView.addSubview(bubbleView)
        
        bubbleView.addSubview(captionLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        ChatFeedMessageCell.layoutContent(for: self)
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
        updateTopLabelStyle(for: usernameLabel)
        updateTopLabelStyle(for: timestampLabel)
        
        bubbleView.backgroundColor = dependencyManager.backgroundColor
        bubbleView.layer.cornerRadius = 6.0
        
        avatarView.layer.borderWidth = 1.0
        avatarView.layer.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.3).CGColor
        avatarView.backgroundColor = dependencyManager.backgroundColor
    }
    
    private func updateTopLabelStyle(for label: UILabel) {
        label.font = dependencyManager.userLabelFont
        label.textColor = dependencyManager.userLabelColor
    }
    
    private func populateData() {
        captionLabel.attributedText = content?.attributedText(using: dependencyManager)
        usernameLabel.text = content?.author.name ?? ""
        updateTimestamp()
        
        let shouldHideTopLabels = content?.wasCreatedByCurrentUser == true
        usernameLabel.hidden = shouldHideTopLabels
        timestampLabel.hidden = shouldHideTopLabels
        
        if let content = content where content.type.hasMedia {
            if content.type == .gif {
                let previewView = createMediaViewIfNeeded()
                setNeedsLayout()
                layoutIfNeeded()
                previewView.content = content
                previewView.hidden = false
            }
            else {
                // Videos and images
                let previewView = createContentPreviewViewIfNeeded()
                setNeedsLayout()
                layoutIfNeeded()
                previewView.hidden = false
                previewView.content = content
            }
        }
        else {
            previewView?.hidden = true
        }
        
        if let imageURL = content?.author.previewImageURL(ofMinimumSize: avatarView.frame.size) {
            avatarView.setProfileImageURL(imageURL)
        }
        else {
            avatarView.image = nil
        }
    }
    
    private func createContentPreviewViewIfNeeded() -> ContentPreviewView {
        if let existingPreviewView = self.previewView as? ContentPreviewView {
            return existingPreviewView
        }
        
        let previewView = ContentPreviewView()
        setupPreviewView(previewView)
        return previewView
    }
    
    private func createMediaViewIfNeeded() -> MediaContentView {
        if let existingMediaView = self.previewView as? MediaContentView {
            return existingMediaView
        }
        
        let previewView = MediaContentView(showsBackground: false)
        
        previewView.animatesBetweenContent = false
        previewView.allowsVideoControls = false
        setupPreviewView(previewView)
        return previewView
    }
    
    private func setupPreviewView(previewView: UIView) {
        previewView.clipsToBounds = true
        previewView.translatesAutoresizingMaskIntoConstraints = false
        
        previewView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onMediaTapped)))
        
        bubbleView.addSubview(previewView)
        self.previewView = previewView
    }
    
    func updateTimestamp() {
        timestampLabel.text = content?.timeLabel ?? ""
    }
    
    // MARK: - Managing lifecycle
    
    /// Expected to be called whenever the cell goes off-screen and is queued for later reuse. Stops media from playing
    /// and frees up resources that are no longer needed.
    func stopDisplaying() {
        if let previewView = previewView as? MediaContentView {
            previewView.videoCoordinator?.pauseVideo()
        }
    }
    
    func startDisplaying() {
        if let previewView = previewView as? MediaContentView {
            previewView.videoCoordinator?.playVideo()
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
    
    var userLabelFont: UIFont {
        return UIFont.boldSystemFontOfSize(12)
    }
    
    var userLabelColor: UIColor {
        return colorForKey("color.username.text") ?? .whiteColor()
    }
}

private extension ContentModel {
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
