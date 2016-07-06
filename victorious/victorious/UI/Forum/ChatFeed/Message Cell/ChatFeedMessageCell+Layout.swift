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
    /// Performs the view layout for `cell` based on its content.
    static func layoutContent(for cell: ChatFeedMessageCell) {
        guard let content = cell.content, dependencyManager = cell.dependencyManager else {
            return
        }
        
        let alignment: ChatFeedMessageCellAlignment = content.wasCreatedByCurrentUser ? .right : .left
        
        let mediaSize = self.mediaSize(displaying: content, inWidth: cell.bounds.width)
        let textSize = self.textSize(displaying: content, inWidth: cell.bounds.width, dependencyManager: dependencyManager)
        let timestampSize = cell.timestampLabel.sizeThatFits(cell.bounds.size)
        let usernameSize = self.usernameSize(in: cell, withTimestampSize: timestampSize)
        
        let contentSize = CGSize(
            width: mediaSize?.width ?? textSize.width,
            height: textSize.height + (mediaSize?.height ?? 0.0)
        )
        
        let bubbleOffset = self.bubbleOffset(forAlignment: alignment, inBounds: cell.bounds, withBubbleSize: contentSize)
        
        // Top label layout:
        
        cell.usernameLabel.frame = CGRect(
            x: bubbleOffset.x + topLabelXInset,
            y: bubbleOffset.y - usernameSize.height - topLabelYSpacing,
            width: usernameSize.width,
            height: usernameSize.height
        )
        
        cell.timestampLabel.frame = CGRect(
            x: bubbleOffset.x + max(usernameSize.width + topLabelXInset * 2.0, contentSize.width - timestampSize.width - topLabelXInset),
            y: bubbleOffset.y - timestampSize.height - topLabelYSpacing,
            width: timestampSize.width,
            height: timestampSize.height
        )
        
        // Avatar layout:
        
        cell.avatarView.frame = CGRect(
            origin: avatarOffset(forAlignment: alignment, inBounds: cell.bounds),
            size: avatarSize
        )
        
        cell.avatarShadowView.frame = cell.avatarView.frame
        
        cell.avatarTapTarget.frame = CGRect(center: cell.avatarView.center, size: avatarTapTargetSize)
        
        // Bubble / content layout:
        
        cell.bubbleView.frame = CGRect(origin: bubbleOffset, size: contentSize)
        
        cell.bubbleBorderView.frame = cell.bubbleView.frame.insetBy(bubbleBackgroundInsets)
        
        cell.previewView?.frame = CGRect(origin: CGPoint.zero, size: mediaSize ?? CGSize.zero)
        
        cell.captionLabel.frame = CGRect(
            x: captionInsets.left,
            y: mediaSize?.height ?? 0.0,
            width: contentSize.width - captionInsets.horizontal,
            height: textSize.height
        )
    }
    
    private static func avatarOffset(forAlignment alignment: ChatFeedMessageCellAlignment, inBounds bounds: CGRect) -> CGPoint {
        switch alignment {
            case .left: return CGPoint(x: horizontalSpacing, y: contentMargin.top)
            case .right: return CGPoint(x: bounds.maxX - horizontalSpacing - avatarSize.width, y: contentMargin.top)
        }
    }
    
    private static func bubbleOffset(forAlignment alignment: ChatFeedMessageCellAlignment, inBounds bounds: CGRect, withBubbleSize bubbleSize: CGSize) -> CGPoint {
        let edgePadding = horizontalSpacing * 2.0 + avatarSize.width
        
        switch alignment {
            case .left: return CGPoint(x: edgePadding, y: contentMargin.top)
            case .right: return CGPoint(x: bounds.maxX - bubbleSize.width - edgePadding, y: contentMargin.top)
        }
    }
    
    private static func usernameSize(in cell: ChatFeedMessageCell, withTimestampSize timestampSize: CGSize) -> CGSize {
        var size = cell.usernameLabel.sizeThatFits(cell.bounds.size)
        size.width = min(size.width, cell.bounds.width - horizontalSpacing * 3.0 - avatarSize.width - topLabelXInset * 3.0 - timestampSize.width)
        return size
    }
}
