//
//  MessageCellDecorator.swift
//  victorious
//
//  Created by Patrick Lynch on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

struct MessageCellDecorator {
    
    func decorateCell(cell: MessageCell, withMessage message: ChatMessage, dependencyManager: VDependencyManager) {
        
        if message.sender.isCurrentUser() {
            cell.layout = RightAlignmentCellLayout()
        } else {
            cell.layout = LeftAlignmentCellLayout()
        }
        
        cell.dependencyManager = dependencyManager
        
        let media: ForumMedia?
        if let url = NSURL(v_string: message.mediaUrl),
            let width = message.mediaWidth?.floatValue,
            let height = message.mediaHeight? .floatValue {
                media = ForumMedia(url: url, width: CGFloat(width), height: CGFloat(height))
        } else {
            media = nil
        }
        
        cell.viewData = MessageCell.ViewData(
            text: message.text,
            timeLabel: message.postedAt.stringDescribingTimeIntervalSinceNow(),
            username: message.sender.name ?? "",
            avatarImageURL: NSURL(v_string: message.sender.pictureUrl),
            media: media
        )
    }
}
