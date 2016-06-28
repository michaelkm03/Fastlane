//
//  ChatFeedMessageCellLayout.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ChatFeedMessageCellLayout {
    func update(for cell: ChatFeedMessageCell)
}

extension ChatFeedMessageCellLayout {
    private func performCommonLayout(for cell: ChatFeedMessageCell) {
        guard let content = cell.content, dependencyManager = cell.dependencyManager else {
            return
        }
        
        let mediaSize = ChatFeedMessageCell.mediaSize(displaying: content, inWidth: cell.bounds.width, dependencyManager: dependencyManager)
        let textSize = ChatFeedMessageCell.textSize(displaying: content, inWidth: cell.bounds.width, dependencyManager: dependencyManager)
        let captionInsets = ChatFeedMessageCell.captionInsets
        
        let contentSize = CGSize(
            width: max(textSize.width, mediaSize.width),
            height: textSize.height + mediaSize.height
        )
        
        cell.bubbleView.frame = CGRect(
            x: 0,
            y: 0,
            width: contentSize.width,
            height: contentSize.height
        )
        
        cell.captionLabel.frame = CGRect(
            x: captionInsets.left,
            y: mediaSize.height,
            width: cell.bubbleView.bounds.width - captionInsets.horizontal,
            height: textSize.height
        )
        
        cell.previewView?.frame = CGRect(
            x: 0,
            y: 0,
            width: cell.bubbleView.bounds.width,
            height: mediaSize.height
        )
    }
}

struct LeftAlignmentCellLayout: ChatFeedMessageCellLayout {
    func update(for cell: ChatFeedMessageCell) {
        let horizontalSpacing = ChatFeedMessageCell.horizontalSpacing
        let avatarSize = ChatFeedMessageCell.avatarSize
        let contentMargin = ChatFeedMessageCell.contentMargin
        
        performCommonLayout(for: cell)
        
        cell.avatarView.frame = CGRect(
            x: 0,
            y: 0,
            width: avatarSize.width,
            height: avatarSize.height
        )
        
        cell.messageContainer.frame = CGRect(
            x: cell.avatarView.frame.maxX + horizontalSpacing,
            y: 0,
            width: cell.bubbleView.bounds.width,
            height: cell.bubbleView.bounds.height
        )
        
        cell.contentContainer.frame = CGRect(
            x: contentMargin.left,
            y: contentMargin.top,
            width: cell.messageContainer.bounds.width
                + horizontalSpacing
                + cell.avatarView.bounds.width,
            height: cell.messageContainer.bounds.height
        )
        
        cell.detailLabel.frame = CGRect(
            x: contentMargin.left + cell.messageContainer.frame.origin.x,
            y: 0,
            width: cell.bounds.width,
            height: contentMargin.top
        )
    }
}

struct RightAlignmentCellLayout: ChatFeedMessageCellLayout {
    func update(for cell: ChatFeedMessageCell) {
        let horizontalSpacing = ChatFeedMessageCell.horizontalSpacing
        let avatarSize = ChatFeedMessageCell.avatarSize
        let contentMargin = ChatFeedMessageCell.contentMargin
        
        performCommonLayout(for: cell)
        
        cell.messageContainer.frame = CGRect(
            x: 0,
            y: 0,
            width: cell.bubbleView.bounds.width,
            height: cell.bubbleView.bounds.height
        )
        
        cell.avatarView.frame = CGRect(
            x: cell.messageContainer.bounds.maxX + horizontalSpacing,
            y: 0,
            width: avatarSize.width,
            height: avatarSize.height
        )
        
        cell.contentContainer.frame = CGRect(
            x: cell.bounds.width
                - cell.messageContainer.bounds.width
                - horizontalSpacing
                - cell.avatarView.bounds.width
                - contentMargin.left,
            y: contentMargin.top,
            width: cell.messageContainer.bounds.width
                + horizontalSpacing
                + cell.avatarView.bounds.width,
            height: cell.messageContainer.bounds.height
        )
        cell.detailLabel.frame = CGRect(
            x: cell.contentContainer.frame.maxX
                - cell.avatarView.frame.width
                - horizontalSpacing
                - cell.detailLabel.frame.width,
            y: 0,
            width: cell.bounds.width,
            height: contentMargin.top
        )
    }
}
