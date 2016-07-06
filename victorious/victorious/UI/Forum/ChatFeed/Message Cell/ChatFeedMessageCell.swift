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
    
    let defaultAvatarImage = UIImage(named: "profile_full")
    
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
    
    static let captionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    static let horizontalSpacing = CGFloat(12.0)
    static let avatarSize = CGSize(width: 30.0, height: 30.0)
    static let avatarTapTargetSize = CGSize(width: 44.0, height: 44.0)
    static let contentMargin = UIEdgeInsets(top: 28.0, left: 10.0, bottom: 2.0, right: 75.0)
    static let topLabelYSpacing = CGFloat(4.0)
    static let topLabelXInset = CGFloat(4.0)
    static let bubbleSpacing = CGFloat(6.0)
    static let shadowRadius = CGFloat(1.0)
    static let shadowOpacity = Float(0.2)
    static let shadowColor = UIColor.blackColor()
    static let shadowOffset = CGSize(width: 0.0, height: 1.0)
    
    // MARK: - Initializing
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        avatarView.clipsToBounds = true
        avatarView.userInteractionEnabled = true
        
        avatarTapTarget.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onAvatarTapped)))
        
        captionLabel.numberOfLines = 0
        
        avatarShadowView.layer.shadowColor = ChatFeedMessageCell.shadowColor.CGColor
        avatarShadowView.layer.shadowRadius = ChatFeedMessageCell.shadowRadius
        avatarShadowView.layer.shadowOpacity = ChatFeedMessageCell.shadowOpacity
        avatarShadowView.layer.shadowOffset = ChatFeedMessageCell.shadowOffset
        
        contentView.addSubview(usernameLabel)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(avatarShadowView)
        contentView.addSubview(avatarView)
        contentView.addSubview(avatarTapTarget)
        contentView.addSubview(captionBubbleView)
        
        captionBubbleView.contentView.addSubview(captionLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    // MARK: - Subviews
    
    let usernameLabel = UILabel()
    let timestampLabel = UILabel()
    
    let avatarShadowView = UIView()
    let avatarView = UIImageView()
    let avatarTapTarget = UIView()
    
    let captionBubbleView = ChatBubbleView()
    let captionLabel = UILabel()
    
    var previewBubbleView: ChatBubbleView?
    var previewView: UIView?
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        ChatFeedMessageCell.layoutContent(for: self)
        avatarView.layer.cornerRadius = avatarView.bounds.size.v_roundCornerRadius
        updateAvatarShadowPathIfNeeded()
    }
    
    // MARK: - Shadows
    
    private var shadowBounds: CGRect?
    
    private func updateAvatarShadowPathIfNeeded() {
        let newShadowBounds = avatarShadowView.bounds
        
        if newShadowBounds != shadowBounds {
            shadowBounds = newShadowBounds
            avatarShadowView.layer.shadowPath = UIBezierPath(ovalInRect: newShadowBounds).CGPath
        }
    }
    
    // MARK: - Gesture Recognizer Actions
    
    func onAvatarTapped(sender: AnyObject?) {
        delegate?.messageCellDidSelectAvatarImage(self)
    }
    
    func onPreviewTapped(sender: AnyObject?) {
        delegate?.messageCellDidSelectMedia(self)
    }
    
    private func updateStyle() {
        usernameLabel.font = dependencyManager.usernameFont
        usernameLabel.textColor = dependencyManager.usernameColor
        
        timestampLabel.font = dependencyManager.timestampFont
        timestampLabel.textColor = dependencyManager.timestampColor
        
        captionBubbleView.backgroundColor = dependencyManager.backgroundColor
        
        avatarView.backgroundColor = dependencyManager.backgroundColor
    }
    
    private func populateData() {
        captionLabel.attributedText = content?.attributedText(using: dependencyManager)
        usernameLabel.text = content?.author.name ?? ""
        updateTimestamp()
        
        let shouldHideTopLabels = content?.wasCreatedByCurrentUser == true
        usernameLabel.hidden = shouldHideTopLabels
        timestampLabel.hidden = shouldHideTopLabels
        
        if let content = content where content.type.hasMedia {
            if content.type == .gif && VCurrentUser.user()?.canView(content) == true {
                let previewView = createMediaViewIfNeeded()
                ChatFeedMessageCell.layoutContent(for: self)
                previewView.content = content
            }
            else {
                // Videos and images
                let previewView = createContentPreviewViewIfNeeded()
                ChatFeedMessageCell.layoutContent(for: self)
                previewView.content = content
            }
            previewView?.hidden = false
        }
        else {
            previewView?.hidden = true
        }

        if let imageURL = content?.author.previewImageURL(ofMinimumSize: avatarView.frame.size) {
            avatarView.sd_setImageWithURL(imageURL, placeholderImage: defaultAvatarImage)
        }
        else {
            avatarView.image = defaultAvatarImage
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
        
        previewView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPreviewTapped)))
        
        let bubbleView = ChatBubbleView()
        bubbleView.contentView.addSubview(previewView)
        addSubview(bubbleView)
        previewBubbleView = bubbleView
        self.previewView = previewView
    }
    
    func updateTimestamp() {
        timestampLabel.text = content?.timeLabel ?? ""
        setNeedsLayout()
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
        let captionHeight = captionSize(displaying: content, inWidth: width, dependencyManager: dependencyManager)?.height ?? 0.0
        let previewHeight = previewSize(displaying: content, inWidth: width)?.height ?? 0.0
        let bubbleSpacing = captionHeight > 0.0 && previewHeight > 0.0 ? self.bubbleSpacing : 0.0
        let contentHeight = max(captionHeight + bubbleSpacing + previewHeight, avatarSize.height)
        return contentMargin.top + contentMargin.bottom + contentHeight
    }
    
    static func captionSize(displaying content: ContentModel, inWidth width: CGFloat, dependencyManager: VDependencyManager) -> CGSize? {
        guard let attributedText = content.attributedText(using: dependencyManager) else {
            return nil
        }
        
        let previewWidth = previewSize(displaying: content, inWidth: width)?.width
        let maxCaptionWidth = min(width - nonContentWidth, previewWidth ?? CGFloat.max)
        
        var size = attributedText.boundingRectWithSize(
            CGSize(width: maxCaptionWidth, height: CGFloat.max),
            options: [.UsesLineFragmentOrigin],
            context: nil
        ).size
        
        size.width += captionInsets.horizontal
        size.height += captionInsets.vertical
        return size
    }
    
    static func previewSize(displaying content: ContentModel, inWidth width: CGFloat) -> CGSize? {
        return content.mediaSize?.preferredSize(clampedToWidth: width - nonContentWidth)
    }
    
    private static var nonContentWidth: CGFloat {
        return contentMargin.horizontal + avatarSize.width + horizontalSpacing
    }
}

private extension ContentModel {
    var timeLabel: String {
        return createdAt.stringDescribingTimeIntervalSinceNow(format: .concise, precision: .seconds)
    }
}

private extension VDependencyManager {
    var messageTextColor: UIColor {
        return colorForKey("color.message.text") ?? .whiteColor()
    }

    var messageFont: UIFont {
        return fontForKey("font.message")
    }

    var backgroundColor: UIColor? {
        return colorForKey("color.message.bubble") ?? .darkGrayColor()
    }
    
    var usernameFont: UIFont {
        return fontForKey("font.username.text")
    }
    
    var usernameColor: UIColor {
        return colorForKey("color.username.text") ?? .whiteColor()
    }
    
    var timestampFont: UIFont {
        return fontForKey("font.timestamp.text")
    }
    
    var timestampColor: UIColor {
        return colorForKey("color.timestamp.text") ?? .whiteColor()
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
