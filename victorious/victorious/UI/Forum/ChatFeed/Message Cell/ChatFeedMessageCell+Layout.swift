//
//  ChatFeedMessageCell+Layout.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// The possible alignment values for the content of a chat feed message cell.
private enum ChatFeedMessageCellAlignment {
    case left, right
}

extension ChatFeedMessageCell {
    // MARK: - Constants

    private struct Constants {
        static let likeViewMargin = CGFloat(16.0)
        static let replyMargin = CGFloat(2.0)
        static let likeViewWidth = CGFloat(66.0)
        static let likeViewHeight = CGFloat(66.0)
        static let replyButtonWidth = CGFloat(44.0)
        static let replyButtonHeight = CGFloat(44.0)
        static let replyHorizontalPadding = CGFloat(8.0)
        static let replyVerticalPadding = CGFloat(4.0)
    }

    /// Performs the view layout for `cell` based on its content.
    static func layoutContent(for cell: ChatFeedMessageCell) {
        guard
            let chatFeedContent = cell.chatFeedContent,
            let dependencyManager = cell.dependencyManager
        else {
            return
        }
        
        let content = chatFeedContent.content
        let alignment: ChatFeedMessageCellAlignment = content.wasCreatedByCurrentUser ? .right : .left
        
        let previewSize = self.previewSize(displaying: content, inWidth: cell.bounds.width)
        let captionSize = self.captionSize(displaying: content, inWidth: cell.bounds.width, dependencyManager: dependencyManager)
        let timestampSize = cell.timestampLabel.sizeThatFits(cell.bounds.size)
        let usernameSize = self.usernameSize(in: cell, withTimestampSize: timestampSize)
        
        // Bubble layout:
        
        let previewFrame = layoutBubbleView(cell.previewBubbleView, forAlignment: alignment, withChatFeedContent: chatFeedContent, size: previewSize, precedingBubbleFrame: nil, inBounds: cell.bounds)
        let captionFrame = layoutBubbleView(cell.captionBubbleView, forAlignment: alignment, withChatFeedContent: chatFeedContent, size: captionSize, precedingBubbleFrame: previewFrame, inBounds: cell.bounds)
        let bubbleFrames = [previewFrame, captionFrame].flatMap { $0 }
        let firstBubbleFrame = bubbleFrames.first ?? CGRect.zero
        
        if let previewFrame = previewFrame {
            cell.spinner.center = CGPoint(x: previewFrame.size.width/2, y: previewFrame.size.height/2)
        }
        
        // Top label layout:
        
        cell.usernameLabel.frame = CGRect(
            x: firstBubbleFrame.origin.x + topLabelXInset,
            y: firstBubbleFrame.origin.y - usernameSize.height - topLabelYSpacing,
            width: usernameSize.width,
            height: usernameSize.height
        )

        cell.timestampLabel.frame = CGRect(
            x: firstBubbleFrame.origin.x + max(usernameSize.width + topLabelXInset * 2.0, firstBubbleFrame.width - timestampSize.width - topLabelXInset),
            y: firstBubbleFrame.origin.y - timestampSize.height - topLabelYSpacing,
            width: timestampSize.width,
            height: timestampSize.height
        )

        // Avatar layout:
        
        cell.avatarView.frame = CGRect(
            origin: avatarOffset(forAlignment: alignment, withChatFeedContent: chatFeedContent, inBounds: cell.bounds),
            size: avatarSize
        )

        cell.avatarTapTarget.frame = CGRect(center: cell.avatarView.center, size: avatarTapTargetSize)

        // Preview / caption layout:
        
        cell.previewView?.frame = cell.previewBubbleView?.bounds ?? CGRect.zero
        
        if let captionFrame = captionFrame {
            cell.captionLabel.frame = CGRect(
                x: captionInsets.left,
                y: 0.0,
                width: captionFrame.width - captionInsets.horizontal,
                height: captionFrame.height
            )
        }
        else {
            cell.captionLabel.frame = CGRect.zero
        }
        
        // Failure button layout:
        
        if alignment == .right && cell.chatFeedContent?.creationState == .failed {
            let avatarFrame = cell.avatarView.frame
            cell.failureButton.frame = CGRect(
                center: CGPoint(
                    x: avatarFrame.origin.x + avatarFrame.size.width + horizontalSpacing + failureButtonSize.width / 2,
                    y: avatarFrame.center.y
                ),
                size: failureButtonSize
            )
        }
        else {
            cell.failureButton.frame = .zero
        }

        // MARK: - Reply button

        if cell.showsReplyButton && alignment == .left {
            cell.replyButton.hidden = false
            let replyButton = cell.replyButton
            if let baseFrame = bubbleFrames.last {
                replyButton.frame = CGRect(
                    x: (baseFrame.maxX - (Constants.replyButtonWidth / 2) - Constants.replyHorizontalPadding),
                    y: (baseFrame.maxY - (Constants.replyButtonHeight / 2) - Constants.replyVerticalPadding),
                    width: Constants.replyButtonWidth,
                    height: Constants.replyButtonHeight
                )

                cell.contentView.bringSubviewToFront(replyButton)
            }
        }
        else {
            cell.replyButton.hidden = true
        }

        // MARK: - Like View
        if let topBubbleFrame = bubbleFrames.first, let bottomBubbleFrame = bubbleFrames.last {
            let likeViewOriginX = alignment == .left ? cell.bounds.size.width - Constants.likeViewWidth - Constants.likeViewMargin : Constants.likeViewMargin
            if let likeView = cell.likeView {
                likeView.frame = CGRect(
                    x: likeViewOriginX,
                    y: topBubbleFrame.minY + (bottomBubbleFrame.maxY - topBubbleFrame.minY - Constants.likeViewHeight) / 2.0,
                    width: Constants.likeViewWidth,
                    height: Constants.likeViewHeight
                )
            }
        }
    }

    private static func layoutBubbleView(bubbleView: UIView?, forAlignment alignment: ChatFeedMessageCellAlignment, withChatFeedContent content: ChatFeedContent, size: CGSize?, precedingBubbleFrame: CGRect?, inBounds bounds: CGRect) -> CGRect? {
        guard let size = size else {
            bubbleView?.frame = CGRect.zero
            return nil
        }
        
        guard let bubbleView = bubbleView else {
            return nil
        }
        
        let avatarXPosition = avatarOffset(forAlignment: alignment, withChatFeedContent: content, inBounds: bounds).x
        let x: CGFloat
        
        switch alignment {
            case .left: x = avatarXPosition + avatarSize.width + horizontalSpacing
            case .right: x = avatarXPosition - size.width - horizontalSpacing
        }
        
        bubbleView.frame = CGRect(
            origin: CGPoint(x: x, y: precedingBubbleFrame.map { $0.maxY + bubbleSpacing } ?? contentMargin.top),
            size: size
        )
        
        return bubbleView.frame
    }
    
    private static func avatarOffset(forAlignment alignment: ChatFeedMessageCellAlignment, withChatFeedContent content: ChatFeedContent, inBounds bounds: CGRect) -> CGPoint {
        switch alignment {
            case .left:
                return CGPoint(x: horizontalSpacing, y: contentMargin.top)
            case .right:
                var x = bounds.maxX - horizontalSpacing - avatarSize.width
                if content.creationState == .failed {
                    x -= (failureButtonSize.width + horizontalSpacing)
                }
                return CGPoint(x: x, y: contentMargin.top)
        }
    }
    
    private static func usernameSize(in cell: ChatFeedMessageCell, withTimestampSize timestampSize: CGSize) -> CGSize {
        var size = cell.usernameLabel.sizeThatFits(cell.bounds.size)
        size.width = min(size.width, cell.bounds.width - horizontalSpacing * 3.0 - avatarSize.width - topLabelXInset * 3.0 - timestampSize.width)
        return size
    }
}
