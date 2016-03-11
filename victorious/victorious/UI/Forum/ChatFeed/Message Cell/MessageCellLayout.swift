//
//  MessageCellLayout.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol MessageCellLayout {
    var textAlignment: NSTextAlignment { get }
    func updateLayout(cell: MessageCell)
}

struct LeftAlignmentCellLayout: MessageCellLayout {
    
    var textAlignment: NSTextAlignment {
        return .Left
    }
    
    func updateLayout(cell: MessageCell) {
        let mediaSize = cell.calculateMediaSize()
        let textSize = cell.calculateTextSize()
        let contentSize = CGSize(
            width: max(textSize.width, mediaSize.width),
            height: textSize.height + mediaSize.height
        )
        
        cell.bubbleView.frame = CGRect(
            x: 0,
            y: cell.detailTextView.frame.height,
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
        
        cell.detailTextView.frame = CGRect(x: 0, y: 0,
            width: cell.bubbleView.bounds.width,
            height: cell.detailTextView.frame.height
        )
        
        cell.avatarContainer.frame = CGRect(
            x: 0,
            y: 0,
            width: cell.avatarContainer.bounds.width,
            height: cell.bubbleView.bounds.height + cell.detailTextView.bounds.height
        )
        cell.messageContainer.frame = CGRect(
            x: cell.avatarContainer.frame.maxX + cell.spacing,
            y: 0,
            width: cell.bubbleView.bounds.width,
            height: cell.bubbleView.bounds.height + cell.detailTextView.bounds.height
        )
        cell.contentContainer.frame = CGRect(
            x: cell.contentMargin.left,
            y: cell.contentMargin.top,
            width: cell.messageContainer.bounds.width + cell.spacing + cell.avatarContainer.bounds.width,
            height: cell.messageContainer.bounds.height
        )
    }
}

struct RightAlignmentCellLayout: MessageCellLayout {
    
    var textAlignment: NSTextAlignment {
        return .Right
    }
    
    func updateLayout(cell: MessageCell) {
        let mediaSize = cell.calculateMediaSize()
        let textSize = cell.calculateTextSize()
        let contentSize = CGSize(
            width: max(textSize.width, mediaSize.width),
            height: textSize.height + mediaSize.height
        )
        cell.bubbleView.frame = CGRect(x: 0,
            y: cell.detailTextView.frame.height,
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
        
        cell.detailTextView.frame = CGRect(x: 0, y: 0,
            width: cell.bubbleView.bounds.width,
            height: cell.detailTextView.frame.height
        )
        cell.messageContainer.frame = CGRect(
            x: 0,
            y: 0,
            width: cell.bubbleView.bounds.width,
            height: cell.bubbleView.bounds.height + cell.detailTextView.bounds.height
        )
        cell.avatarContainer.frame = CGRect(
            x: cell.messageContainer.bounds.width + cell.spacing,
            y: 0,
            width: cell.avatarContainer.bounds.width,
            height: cell.messageContainer.bounds.height
        )
        cell.contentContainer.frame = CGRect(
            x: cell.bounds.width - (cell.messageContainer.bounds.width + cell.spacing + cell.avatarContainer.bounds.width) - cell.contentMargin.left,
            y: cell.contentMargin.top,
            width: cell.messageContainer.bounds.width + cell.spacing + cell.avatarContainer.bounds.width,
            height: cell.messageContainer.bounds.height
        )
    }
}
