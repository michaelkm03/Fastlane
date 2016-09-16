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
    func messageCellDidLongPressContent(messageCell: ChatFeedMessageCell)
    func messageCellDidSelectFailureButton(messageCell: ChatFeedMessageCell)
}

class ChatFeedMessageCell: UICollectionViewCell, MediaContentViewDelegate {
    
    // MARK: - Constants
    
    // We don't use a Constants struct to allow for easy access to these values from our static layout methods.
    
    static let captionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    static let horizontalSpacing = CGFloat(12.0)
    static let avatarSize = CGSize(width: 30.0, height: 30.0)
    static let avatarTapTargetSize = CGSize(width: 44.0, height: 44.0)
    static let failureButtonSize = CGSize(width: 24.0, height: 24.0)
    static let contentMargin = UIEdgeInsets(top: 28.0, left: 10.0, bottom: 2.0, right: 75.0)
    static let topLabelYSpacing = CGFloat(4.0)
    static let topLabelXInset = CGFloat(4.0)
    static let bubbleSpacing = CGFloat(6.0)
    static let pendingContentAlpha = CGFloat(0.4)
    
    // MARK: - Reuse identifiers
    
    static let imagePreviewCellReuseIdentifier = "ImagePreviewChatFeedMessageCell"
    static let videoPreviewCellReuseIdentifier = "VideoPreviewChatFeedMessageCell"
    static let nonMediaCellReuseIdentifier = "NonMediaChatFeedMessageCell"
    
    // MARK: - Initializing
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        avatarTapTarget.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnAvatar)))
        captionBubbleView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPressBubble)))
        failureButton.addTarget(self, action: #selector(didTapOnFailureButton), forControlEvents: .TouchUpInside)
        captionLabel.numberOfLines = 0
        captionLabel.userInteractionEnabled = false
        likeButton.addTarget(self, action: #selector(didTapOnLikeButton), forControlEvents: .TouchUpInside)
        replyButton.addTarget(self, action: #selector(didTapOnReplyButton), forControlEvents: .TouchUpInside)
        
        contentView.addSubview(usernameLabel)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(likeCountLabel)
        contentView.addSubview(avatarView)
        contentView.addSubview(avatarTapTarget)
        contentView.addSubview(captionBubbleView)
        contentView.addSubview(failureButton)
        contentView.addSubview(likeButton)
        contentView.addSubview(replyButton)
        
        captionBubbleView.contentView.addSubview(captionLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    // MARK: - Configuration
    
    weak var delegate: ChatFeedMessageCellDelegate?
    
    var dependencyManager: VDependencyManager! {
        didSet {
            if dependencyManager != oldValue {
                updateStyle()
            }
        }
    }
    
    // MARK: - Content
    
    var chatFeedContent: ChatFeedContent? {
        didSet {
            // Updating the content is expensive, so we try to bail if we're setting the same content as before.
            // However, chat message contents don't have IDs, so we can't do this if the ID is nil.
            let oldID = oldValue?.content.id
            let newID = chatFeedContent?.content.id
            
            guard newID != oldID || newID == nil else {
                return
            }
            
            populateData()
            setNeedsLayout()
        }
    }

    /// Provides a private shorthand accessor within the implementation because we mostly deal with the ContentModel
    private var content: ContentModel? {
        return chatFeedContent?.content
    }
    
    // MARK: - Subviews
    
    let usernameLabel = UILabel()
    let timestampLabel = UILabel()
    let likeCountLabel = UILabel()
    
    let avatarView = AvatarView()
    let avatarTapTarget = UIView()
    
    let captionBubbleView = BubbleView()
    let captionLabel = UILabel()
    
    var previewBubbleView: BubbleView?
    var previewView: UIView?
    
    let failureButton = UIButton(type: .Custom)
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)

    let likeButton = UIButton()
    let replyButton = UIButton()
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.alpha = chatFeedContent?.alpha ?? 1.0
        ChatFeedMessageCell.layoutContent(for: self)
    }
    
    // MARK: - Gesture Recognizer Actions
    
    private dynamic func didTapOnAvatar(sender: AnyObject?) {
        delegate?.messageCellDidSelectAvatarImage(self)
    }
    
    private dynamic func didTapOnPreview(sender: AnyObject?) {
        delegate?.messageCellDidSelectMedia(self)
    }
    
    private dynamic func didLongPressBubble(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
            case .Began: delegate?.messageCellDidLongPressContent(self)
            case .Changed, .Cancelled, .Ended, .Failed, .Possible: break
        }
    }
    
    private dynamic func didTapOnFailureButton(sender: UIButton) {
        delegate?.messageCellDidSelectFailureButton(self)
    }

    private dynamic func didTapOnLikeButton(sender: UIButton) {
        sender.selected = !sender.selected
        toggleUpvote()
    }

    func toggleUpvote() {
        guard
            let content = content,
            let contentID = content.id,
            let upvoteAPIPath = dependencyManager.contentUpvoteAPIPath,
            let unupvoteAPIPath = dependencyManager.contentUnupvoteAPIPath,
            let upvoteOperation: SyncOperation<Void> = content.isLikedByCurrentUser
                ? ContentUnupvoteOperation(apiPath: unupvoteAPIPath, contentID: contentID)
                : ContentUpvoteOperation(apiPath: upvoteAPIPath, contentID: contentID)
            else {
                return
        }

        upvoteOperation.queue { [weak self] _ in
            self?.updateLikeCount()
        }
    }

    private dynamic func didTapOnReplyButton(sender: UIButton) {
        print("Tapped on reply button")
    }
    
    // MARK: - Private helper methods
    
    private func updateStyle() {
        usernameLabel.font = dependencyManager.usernameFont
        usernameLabel.textColor = dependencyManager.usernameColor

        timestampLabel.font = dependencyManager.timestampFont
        timestampLabel.textColor = dependencyManager.timestampColor

        likeCountLabel.font = dependencyManager.timestampFont
        likeCountLabel.textColor = dependencyManager.timestampColor

        captionBubbleView.backgroundColor = dependencyManager.backgroundColor
        
        failureButton.setImage(UIImage(named: "failed_error"), forState: .Normal)

        likeButton.setImage(UIImage(named: "heart"), forState: .Normal)
        likeButton.setImage(UIImage(named: "heart_tap"), forState: .Highlighted)
        likeButton.setImage(UIImage(named: "heart_tap"), forState: .Selected)

        replyButton.setImage(UIImage(named: "reply"), forState: .Normal)
        replyButton.setImage(UIImage(named: "heart_tap"), forState: .Highlighted)
        replyButton.setImage(UIImage(named: "heart_tap"), forState: .Selected)

        // FUTURE: - Implemented by Community team
        replyButton.hidden = true
    }

    private func populateData() {
        captionLabel.attributedText = content?.attributedText(using: dependencyManager)
        usernameLabel.text = content?.author.username ?? ""
        updateTimestamp()
        updateLikeCount()
        likeButton.selected = content?.isLikedByCurrentUser ?? false

        let shouldHideTopLabels = content?.wasCreatedByCurrentUser == true
        usernameLabel.hidden = shouldHideTopLabels
        timestampLabel.hidden = shouldHideTopLabels
        likeCountLabel.hidden = true
        likeButton.selected = content?.isLikedByCurrentUser ?? false
        
        if let content = content where content.type.hasMedia {
            if content.type == .gif && VCurrentUser.user?.canView(content) == true {
                let mediaContentView = setupMediaView(for: content)
                mediaContentView.alpha = 0.0
                spinner.startAnimating()
                previewView = mediaContentView
                mediaContentView.loadContent()
                
                ChatFeedMessageCell.layoutContent(for: self)
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
        
        avatarView.user = content?.author
    }
    
    private func createContentPreviewViewIfNeeded() -> ContentPreviewView {
        if let existingPreviewView = self.previewView as? ContentPreviewView {
            return existingPreviewView
        }
        
        let previewView = ContentPreviewView(loadingSpinnerEnabled: true)
        previewView.dependencyManager = dependencyManager
        setupPreviewView(previewView)
        return previewView
    }
    
    private func setupMediaView(for content: ContentModel) -> MediaContentView {
        self.previewView?.removeFromSuperview()
        self.previewView = nil
        
        let previewView = MediaContentView(
            content: content,
            dependencyManager: dependencyManager,
            fillMode: .fill,
            allowsVideoControls: false
        )
        previewView.delegate = self
        
        setupPreviewView(previewView)
        return previewView
    }
    
    private func setupPreviewView(previewView: UIView) {
        previewView.clipsToBounds = true
        previewView.translatesAutoresizingMaskIntoConstraints = false
        
        previewView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnPreview)))
        
        // FUTURE: Reuse the bubble view so that we don't keep removing + adding subviews.
        previewBubbleView?.removeFromSuperview()
        
        let bubbleView = BubbleView()
        bubbleView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPressBubble)))
        bubbleView.backgroundColor = dependencyManager.backgroundColor
        bubbleView.contentView.addSubview(spinner)
        bubbleView.contentView.addSubview(previewView)
        contentView.addSubview(bubbleView)
        previewBubbleView = bubbleView
        self.previewView = previewView
    }

    func updateTimestamp() {
        timestampLabel.text = content?.timeLabel ?? ""
        setNeedsLayout()
    }

    func updateLikeCount() {
        var likesText = "0 likes"

        if let content = content {
            let likeCount = content.likeCount ?? 0
            let localLike = content.isLikedByCurrentUser ? 1 : 0
            let totalLikes = likeCount + localLike
            likesText = totalLikes == 1 ? "1 like" : "\(likeCount) likes"
        }

        likeCountLabel.text = likesText
        setNeedsLayout()
    }

    // MARK: - Managing lifecycle
    
    /// Expected to be called whenever the cell goes off-screen and is queued for later reuse. Stops media from playing
    /// and frees up resources that are no longer needed.
    func stopDisplaying() {
        if let previewView = previewView as? MediaContentView {
            previewView.willBeDismissed()
        }
    }
    
    func startDisplaying() {
        if let previewView = previewView as? MediaContentView {
            previewView.didPresent()
        }
    }
    
    // MARK: - Sizing
    
    static func cellHeight(displaying content: ContentModel, inWidth width: CGFloat, dependencyManager: VDependencyManager) -> CGFloat? {
        let captionHeight = captionSize(displaying: content, inWidth: width, dependencyManager: dependencyManager)?.height ?? 0.0
        let previewHeight = previewSize(displaying: content, inWidth: width)?.height ?? 0.0
        
        if captionHeight == 0.0 && previewHeight == 0.0 {
            return nil //Invalid content
        }
    
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
        guard content.type.hasMedia else {
            return nil
        }
        
        return content.mediaSize?.preferredSize(clampedToWidth: width - nonContentWidth) ?? CGSize(width: width / 2, height: width / 2)
    }
    
    private static var nonContentWidth: CGFloat {
        return contentMargin.horizontal + avatarSize.width + horizontalSpacing
    }
    
    // MARK: - MediaContentViewDelegate
    
    func mediaContentView(mediaContentView: MediaContentView, didFinishLoadingContent content: ContentModel) {
        UIView.animateWithDuration(
            MediaContentView.AnimationConstants.mediaContentViewAnimationDuration,
            animations: {
                mediaContentView.alpha = 1.0
            },
            completion: { [weak self]  _ in
                if mediaContentView === self?.previewView {
                    self?.spinner.stopAnimating()
                }
            }
        )
    }
    
    func mediaContentView(mediaContentView: MediaContentView, didFinishPlaybackOfContent content: ContentModel) {
        // No behavior yet
    }
}

private extension ContentModel {
    var timeLabel: String {
        return NSDate(timestamp: createdAt).stringDescribingTimeIntervalSinceNow(format: .concise, precision: .seconds)
    }
}

private extension ContentCreationState {
    var alpha: CGFloat {
        return self == .failed ? 1.0 : ChatFeedMessageCell.pendingContentAlpha
    }
}

private extension ChatFeedContent {
    var alpha: CGFloat {
        switch content.type {
            case .text:
                return 1.0
            case .gif, .image, .link, .video:
                return creationState?.alpha ?? 1.0
        }
    }
}

private extension VDependencyManager {
    var messageTextColor: UIColor {
        return colorForKey("color.message.text") ?? .whiteColor()
    }

    var messageFont: UIFont {
        return fontForKey("font.message") ?? UIFont.systemFontOfSize(16.0)
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

    var contentUpvoteAPIPath: APIPath? {
        return networkResources?.apiPathForKey("contentUpvoteURL")
    }

    var contentUnupvoteAPIPath: APIPath? {
        return networkResources?.apiPathForKey("contentUnupvoteURL")
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
