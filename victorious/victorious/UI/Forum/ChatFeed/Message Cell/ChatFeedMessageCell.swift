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
    func messageCellDidToggleLikeContent(messageCell: ChatFeedMessageCell, completion: (() -> Void))
    func messageCellDidSelectFailureButton(messageCell: ChatFeedMessageCell)
    func messageCellDidSelectReplyButton(messageCell: ChatFeedMessageCell)
    func messageCell(messageCell: ChatFeedMessageCell, didSelectLinkURL url: NSURL)
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
    static let likeViewSize = CGSize(width: 66.0, height: 66.0)
    static let replyButtonSize = CGSize(width: 44.0, height: 44.0)
    
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
        replyButton.addTarget(self, action: #selector(didTapOnReplyButton), forControlEvents: .TouchUpInside)
        
        contentView.addSubview(usernameLabel)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(avatarView)
        contentView.addSubview(avatarTapTarget)
        contentView.addSubview(captionBubbleView)
        contentView.addSubview(failureButton)
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
    
    var showsReplyButton = true {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: - Content
    
    var chatFeedContent: ChatFeedContent? {
        didSet {
            populateData()
            setNeedsLayout()
        }
    }
    
    /// Provides a private shorthand accessor within the implementation because we mostly deal with the Content
    private var content: Content? {
        return chatFeedContent?.content
    }

    // MARK: - Subviews
    
    let usernameLabel = UILabel()
    let timestampLabel = UILabel()
    
    let avatarView = AvatarView()
    let avatarTapTarget = UIView()
    
    let captionBubbleView = BubbleView()
    let captionLabel = LinkLabel()
    var previewBubbleView: BubbleView?
    var previewView: UIView?

    let failureButton = UIButton(type: .Custom)

    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)

    var likeView: LikeView?
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

    private dynamic func didTapOnLikeView() {
        if let content = content where !content.isLikedByCurrentUser {
            likeView?.animateLike()
        }

        toggleLike()
    }

    private dynamic func didTapOnReplyButton(sender: UIButton) {
        delegate?.messageCellDidSelectReplyButton(self)
    }
    
    // MARK: - Private helper methods
    
    private func updateStyle() {
        captionLabel.textColor = dependencyManager.messageTextColor
        captionLabel.tintColor = dependencyManager.messageLinkColor
        captionLabel.font = dependencyManager.messageFont
        
        usernameLabel.font = dependencyManager.usernameFont
        usernameLabel.textColor = dependencyManager.usernameColor

        timestampLabel.font = dependencyManager.timestampFont
        timestampLabel.textColor = dependencyManager.timestampColor
        captionBubbleView.backgroundColor = dependencyManager.backgroundColor

        failureButton.setImage(UIImage(named: "failed_error"), forState: .Normal)

        if dependencyManager.upvoteStyle == UpvoteStyle.basic {
            likeView = LikeView(
                frame: CGRect.zero,
                textColor: dependencyManager.upvoteCountColor,
                alignment: .center,
                selectedIcon: dependencyManager.upvoteIconSelected,
                unselectedIcon: dependencyManager.upvoteIconUnselected
            )
            if let likeView = likeView {
                likeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnLikeView)))
                contentView.addSubview(likeView)
            }
        }

        replyButton.setImage(UIImage(named: "reply"), forState: .Normal)
        replyButton.setImage(UIImage(named: "reply_tap"), forState: .Highlighted)
        replyButton.setImage(UIImage(named: "reply_tap"), forState: .Selected)
    }

    private func populateData() {
        captionLabel.detectUserTags(for: content) { [weak self] url in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.delegate?.messageCell(strongSelf, didSelectLinkURL: url)
        }
        
        captionLabel.text = content?.text
        usernameLabel.text = content?.author?.username ?? ""
        
        updateTimestamp()
        likeView?.updateLikeStatus(content)

        let shouldHideTopLabels = content?.wasCreatedByCurrentUser == true
        usernameLabel.hidden = shouldHideTopLabels
        timestampLabel.hidden = shouldHideTopLabels

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
    
    private func setupMediaView(for content: Content) -> MediaContentView {
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

    private func toggleLike() {
        guard let content = content else {
            return
        }

        delegate?.messageCellDidToggleLikeContent(self) { [weak self] in
            self?.likeView?.updateLikeStatus(content)
        }
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
            previewView.willBeDismissed()
        }
    }
    
    func startDisplaying() {
        if let previewView = previewView as? MediaContentView {
            previewView.didPresent()
        }
    }
    
    // MARK: - Sizing
    
    static func cellHeight(displaying content: Content, inWidth width: CGFloat, dependencyManager: VDependencyManager) -> CGFloat? {
        let captionHeight = captionSize(displaying: content, inWidth: width, dependencyManager: dependencyManager)?.height ?? 0.0
        let previewHeight = previewSize(displaying: content, inWidth: width)?.height ?? 0.0
        
        if captionHeight == 0.0 && previewHeight == 0.0 {
            return nil //Invalid content
        }
    
        let contentHeight = max(captionHeight + bubbleSpacing + previewHeight, avatarSize.height)
        return contentMargin.top + contentMargin.bottom + contentHeight
    }
    
    static func captionSize(displaying content: Content, inWidth width: CGFloat, dependencyManager: VDependencyManager) -> CGSize? {
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
    
    static func previewSize(displaying content: Content, inWidth width: CGFloat) -> CGSize? {
        guard content.type.hasMedia else {
            return nil
        }
        
        return content.mediaSize?.preferredSize(clampedToWidth: width - nonContentWidth) ?? CGSize(width: width / 2, height: width / 2)
    }
    
    private static var nonContentWidth: CGFloat {
        return contentMargin.horizontal + avatarSize.width + horizontalSpacing
    }
    
    // MARK: - MediaContentViewDelegate
    
    func mediaContentView(mediaContentView: MediaContentView, didFinishLoadingContent content: Content) {
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
    
    func mediaContentView(mediaContentView: MediaContentView, didFinishPlaybackOfContent content: Content) {
        // No behavior yet
    }
    
    func mediaContentView(mediaContentView: MediaContentView, didSelectLinkURL url: NSURL) {
        delegate?.messageCell(self, didSelectLinkURL: url)
    }
}

private extension Content {
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
            case .gif, .image, .link, .video, .sticker:
                return creationState?.alpha ?? 1.0
        }
    }
}

private extension VDependencyManager {
    var messageTextColor: UIColor {
        return colorForKey("color.message.text") ?? .whiteColor()
    }
    
    var messageLinkColor: UIColor {
        return colorForKey("color.message.link") ?? .blueColor()
    }
    
    var messageFont: UIFont {
        return fontForKey("font.message") ?? UIFont.systemFontOfSize(16.0)
    }

    var backgroundColor: UIColor {
        return colorForKey("color.message.bubble") ?? .darkGrayColor()
    }
    
    var usernameFont: UIFont {
        return fontForKey("font.username.text") ?? UIFont.systemFontOfSize(12.0)
    }
    
    var usernameColor: UIColor {
        return colorForKey("color.username.text") ?? .whiteColor()
    }
    
    var timestampFont: UIFont {
        return fontForKey("font.timestamp.text") ?? UIFont.systemFontOfSize(12.0)
    }
    
    var timestampColor: UIColor {
        return colorForKey("color.timestamp.text") ?? .whiteColor()
    }
    
    var upvoteCountColor: UIColor {
        return colorForKey("color.upvote.count.text") ?? .whiteColor()
    }

    var upvoteStyle: UpvoteStyle {
        guard let upvoteStyle = stringForKey("upvote.type") else {
            return .off
        }
        return UpvoteStyle(rawValue: upvoteStyle) ?? .off
    }

    var upvoteIconSelected: UIImage? {
        return imageForKey("upvote.icon.selected")
    }

    var upvoteIconUnselected: UIImage? {
        return imageForKey("upvote.icon.unselected")
    }
}

private enum UpvoteStyle: String {
    case off = "off"
    case basic = "basic"
    case rightHandSide = "right_hand_side"
}

private extension Content {
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
