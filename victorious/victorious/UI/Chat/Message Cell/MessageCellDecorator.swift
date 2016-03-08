//
//  MessageCellDecorator.swift
//  victorious
//
//  Created by Patrick Lynch on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

struct MessageCellDecorator {
    
    let dependencyManager: VDependencyManager
    
    func decorateCell( cell: MessageCell, withMessage message: VMessage) {
        
        if message.sender.isCurrentUser() {
            cell.alignmentDecorator = RightAlignmentCellLayout()
        } else {
            cell.alignmentDecorator = LeftAlignmentCellLayout()
        }
        
        cell.dependencyManager = dependencyManager
        
        let media: MessageCell.Media?
        if let url = NSURL(v_string: message.mediaUrl),
            let width = message.mediaWidth?.floatValue,
            let height = message.mediaHeight?.floatValue {
                media = MessageCell.Media(url: url, width: CGFloat(width), height: CGFloat(height))
        } else {
            media = nil
        }
        
        cell.viewData = MessageCell.ViewData(
            text: "\(message.text ?? "")",
            createdAt: message.postedAt,
            username: message.sender.name ?? "",
            avatarImageURL: NSURL(v_string: message.sender.pictureUrl),
            media: media
        )
    }
}
