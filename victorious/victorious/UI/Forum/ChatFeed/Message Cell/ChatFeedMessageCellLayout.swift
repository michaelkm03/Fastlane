//
//  ChatFeedMessageCellLayout.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ChatFeedMessageCellLayout {
    var textAlignment: NSTextAlignment { get }
    func updateWithCell(cell: ChatFeedMessageCell)
}

struct LeftAlignmentCellLayout: ChatFeedMessageCellLayout {
    
    let textAlignment: NSTextAlignment = .Left
    
    func updateWithCell(cell: ChatFeedMessageCell) {
        let mediaSize = cell.calculateMediaSizeWithinBounds(cell.bounds)
        let textSize = cell.calculateTextSizeWithinBounds(cell.bounds)
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
        cell.textView.frame = CGRect(
            x: 0,
            y: mediaSize.height,
            width: cell.bubbleView.bounds.width,
            height: textSize.height
        )
        cell.mediaView.frame = CGRect(
            x: 0,
            y: 0,
            width: cell.bubbleView.bounds.width,
            height: mediaSize.height
        )
        cell.avatarView.frame = CGRect(
            x: 0,
            y: 0,
            width: cell.avatarSize.width,
            height: cell.avatarSize.height
        )
        cell.messageContainer.frame = CGRect(
            x: cell.avatarView.frame.maxX + cell.horizontalSpacing,
            y: 0,
            width: cell.bubbleView.bounds.width,
            height: cell.bubbleView.bounds.height
        )
        cell.contentContainer.frame = CGRect(
            x: cell.contentMargin.left,
            y: cell.contentMargin.top,
            width: cell.messageContainer.bounds.width
                + cell.horizontalSpacing
                + cell.avatarView.bounds.width,
            height: cell.messageContainer.bounds.height
        )
        cell.detailTextView.frame = CGRect(
            x: cell.contentMargin.left + cell.messageContainer.frame.origin.x,
            y: 0,
            width: cell.bounds.width,
            height: cell.contentMargin.top
        )
    }
}

struct RightAlignmentCellLayout: ChatFeedMessageCellLayout {
    
    let textAlignment: NSTextAlignment = .Right
    
    func updateWithCell(cell: ChatFeedMessageCell) {
        let mediaSize = cell.calculateMediaSizeWithinBounds(cell.bounds)
        let textSize = cell.calculateTextSizeWithinBounds(cell.bounds)
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
        cell.textView.frame = CGRect(
            x: 0,
            y: mediaSize.height,
            width: cell.bubbleView.bounds.width,
            height: textSize.height
        )
        cell.mediaView.frame = CGRect(
            x: 0,
            y: 0,
            width: cell.bubbleView.bounds.width,
            height: mediaSize.height
        )
        cell.messageContainer.frame = CGRect(
            x: 0,
            y: 0,
            width: cell.bubbleView.bounds.width,
            height: cell.bubbleView.bounds.height
        )
        cell.avatarView.frame = CGRect(
            x: cell.messageContainer.bounds.width + cell.horizontalSpacing,
            y: 0,
            width: cell.avatarSize.width,
            height: cell.avatarSize.height
        )
        cell.contentContainer.frame = CGRect(
            x: cell.bounds.width
                - cell.messageContainer.bounds.width
                - cell.horizontalSpacing
                - cell.avatarView.bounds.width
                - cell.contentMargin.left,
            y: cell.contentMargin.top,
            width: cell.messageContainer.bounds.width
                + cell.horizontalSpacing
                + cell.avatarView.bounds.width,
            height: cell.messageContainer.bounds.height
        )
        
        cell.detailTextView.frame = CGRect(
            x: cell.contentContainer.frame.maxX
                - cell.avatarView.frame.width
                - cell.horizontalSpacing
                - cell.detailTextView.frame.width,
            y: 0,
            width: cell.bounds.width,
            height: cell.contentMargin.top
        )
    }
}
