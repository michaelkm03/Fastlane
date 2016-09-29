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
    func messageCellDidSelectAvatarImage(_ messageCell: ChatFeedMessageCell)
    func messageCellDidSelectMedia(_ messageCell: ChatFeedMessageCell)
    func messageCellDidLongPressContent(_ messageCell: ChatFeedMessageCell)
    func messageCellDidToggleLikeContent(_ messageCell: ChatFeedMessageCell, completion: (() -> Void))
    func messageCellDidSelectFailureButton(_ messageCell: ChatFeedMessageCell)
    func messageCellDidSelectReplyButton(_ messageCell: ChatFeedMessageCell)
    func messageCell(_ messageCell: ChatFeedMessageCell, didSelectLinkURL url: URL)
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
        failureButton.addTarget(self, action: #selector(didTapOnFailureButton), for: .touchUpInside)
        captionLabel.numberOfLines = 0
        replyButton.addTarget(self, action: #selector(didTapOnReplyButton), for: .touchUpInside)
        
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
    fileprivate var content: Content? {
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

    let failureButton = UIButton(type: .custom)

    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    var likeView: LikeView?
    let replyButton = UIButton()
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.alpha = chatFeedContent?.alpha ?? 1.0
        ChatFeedMessageCell.layoutContent(for: self)
    }
    
    // MARK: - Gesture Recognizer Actions
    
    fileprivate dynamic func didTapOnAvatar(_ sender: AnyObject?) {
        delegate?.messageCellDidSelectAvatarImage(self)
    }
    
    fileprivate dynamic func didTapOnPreview(_ sender: AnyObject?) {
        delegate?.messageCellDidSelectMedia(self)
    }
    
    fileprivate dynamic func didLongPressBubble(_ recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
            case .began: delegate?.messageCellDidLongPressContent(self)
            case .changed, .cancelled, .ended, .failed, .possible: break
        }
    }
    
    fileprivate dynamic func didTapOnFailureButton(_ sender: UIButton) {
        delegate?.messageCellDidSelectFailureButton(self)
    }

    fileprivate dynamic func didTapOnLikeView() {
        if let content = content , !content.isLikedByCurrentUser {
            likeView?.animateLike()
        }

        toggleLike()
    }

    fileprivate dynamic func didTapOnReplyButton(_ sender: UIButton) {
        delegate?.messageCellDidSelectReplyButton(self)
    }
    
    // MARK: - Private helper methods
    
    fileprivate func updateStyle() {
        captionLabel.textColor = dependencyManager.messageTextColor
        captionLabel.tintColor = dependencyManager.messageLinkColor
        captionLabel.font = dependencyManager.messageFont
        
        usernameLabel.font = dependencyManager.usernameFont
        usernameLabel.textColor = dependencyManager.usernameColor

        timestampLabel.font = dependencyManager.timestampFont
        timestampLabel.textColor = dependencyManager.timestampColor
        captionBubbleView.backgroundColor = dependencyManager.backgroundColor

        failureButton.setImage(UIImage(named: "failed_error"), for: UIControlState())

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

        replyButton.setImage(UIImage(named: "reply"), for: UIControlState())
        replyButton.setImage(UIImage(named: "reply_tap"), for: .highlighted)
        replyButton.setImage(UIImage(named: "reply_tap"), for: .selected)
    }

    fileprivate func populateData() {
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

        if let content = content , content.type.hasMedia {
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
            previewView?.isHidden = false
        }
        else {
            previewView?.isHidden = true
        }
        
        avatarView.user = content?.author
    }
    
    fileprivate func createContentPreviewViewIfNeeded() -> ContentPreviewView {
        if let existingPreviewView = self.previewView as? ContentPreviewView {
            return existingPreviewView
        }
        
        let previewView = ContentPreviewView(loadingSpinnerEnabled: true)
        previewView.dependencyManager = dependencyManager
        setupPreviewView(previewView)
        return previewView
    }
    
    fileprivate func setupMediaView(for content: Content) -> MediaContentView {
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
    
    fileprivate func setupPreviewView(_ previewView: UIView) {
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

    fileprivate func toggleLike() {
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
    
    fileprivate static var nonContentWidth: CGFloat {
        return contentMargin.horizontal + avatarSize.width + horizontalSpacing
    }
    
    // MARK: - MediaContentViewDelegate
    
    func mediaContentView(_ mediaContentView: MediaContentView, didFinishLoadingContent content: Content) {
        UIView.animate(
            withDuration: MediaContentView.AnimationConstants.mediaContentViewAnimationDuration,
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
    
    func mediaContentView(_ mediaContentView: MediaContentView, didFinishPlaybackOfContent content: Content) {
        // No behavior yet
    }
    
    func mediaContentView(_ mediaContentView: MediaContentView, didSelectLinkURL url: URL) {
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
            case .gif, .image, .link, .video:
                return creationState?.alpha ?? 1.0
        }
    }
}

private extension VDependencyManager {
    var messageTextColor: UIColor {
        return color(forKey: "color.message.text") ?? .white
    }
    
    var messageLinkColor: UIColor {
        return color(forKey: "color.message.link") ?? .blue
    }
    
    var messageFont: UIFont {
        return font(forKey: "font.message") ?? UIFont.systemFontOfSize(16.0)
    }

    var backgroundColor: UIColor {
        return color(forKey: "color.message.bubble") ?? .darkGray
    }
    
    var usernameFont: UIFont {
        return font(forKey: "font.username.text") ?? UIFont.systemFontOfSize(12.0)
    }
    
    var usernameColor: UIColor {
        return color(forKey: "color.username.text") ?? .white
    }
    
    var timestampFont: UIFont {
        return font(forKey: "font.timestamp.text") ?? UIFont.systemFontOfSize(12.0)
    }
    
    var timestampColor: UIColor {
        return color(forKey: "color.timestamp.text") ?? .white
    }
    
    var upvoteCountColor: UIColor {
        return color(forKey: "color.upvote.count.text") ?? .white
    }

    var upvoteStyle: UpvoteStyle {
        guard let upvoteStyle = string(forKey: "upvote.type") else {
            return .off
        }
        return UpvoteStyle(rawValue: upvoteStyle) ?? .off
    }

    var upvoteIconSelected: UIImage? {
        return image(forKey: "upvote.icon.selected")
    }

    var upvoteIconUnselected: UIImage? {
        return image(forKey: "upvote.icon.unselected")
    }
}

private enum UpvoteStyle: String {
    case off = "off"
    case basic = "basic"
    case rightHandSide = "right_hand_side"
}

private extension Content {
    func attributedText(using dependencyManager: VDependencyManager) -> NSAttributedString? {
        guard let text = text , text != "" else {
            return nil
        }
        
        return NSAttributedString(string: text, attributes: [
            NSForegroundColorAttributeName: dependencyManager.messageTextColor,
            NSFontAttributeName: dependencyManager.messageFont
        ])
    }
}
