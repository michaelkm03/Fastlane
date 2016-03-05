//
//  MessageCollectionCellDecorator.swift
//  victorious
//
//  Created by Patrick Lynch on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension NSURL {
    convenience init?(v_string string: String?) {
        guard let string = string where !string.characters.isEmpty else {
            self.init(string: "")
            return nil
        }
        self.init(string: string)
    }
}


struct MessageCollectionCellDecorator {
    
    let dependencyManager: VDependencyManager
    
    func decorateCell( cell: VMessageCollectionCell, withMessage message: VMessage) {
        
        if message.sender.isCurrentUser() {
            cell.alignmentDecorator = RightAlignmentDecorator()
        } else {
            cell.alignmentDecorator = LeftAlignmentDecorator()
        }
        
        cell.dependencyManager = dependencyManager
        
        
        cell.viewData = VMessageCollectionCell.ViewData(
            text: "\(message.text ?? "")",
            createdAt: message.postedAt,
            username: message.sender.name ?? "",
            avatarImageURL: NSURL(string: message.sender.pictureUrl ?? ""),
            mediaURL: NSURL(v_string: message.mediaUrl)
        )
        
        cell.mediaContainer.frame = cell.contentContainer.bounds
    }
}

protocol AlignmentDecorator {
    func updateLayout(cell: VMessageCollectionCell)
}

struct LeftAlignmentDecorator: AlignmentDecorator {
    
    func updateLayout(cell: VMessageCollectionCell) {
        let textSize = cell.calculateContentSize()
        
        cell.textView.textAlignment = .Left
        cell.bubbleView.frame = CGRect(x: 0,
            y: cell.detailTextView.frame.height,
            width: textSize.width,
            height: textSize.height
        )
        cell.textView.frame = cell.bubbleView.bounds
        
        cell.mediaContainer.frame = cell.bubbleView.bounds
        
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

struct RightAlignmentDecorator: AlignmentDecorator {
    
    func updateLayout(cell: VMessageCollectionCell) {
        let textSize = cell.calculateContentSize()
        
        cell.textView.textAlignment = .Right
        cell.bubbleView.frame = CGRect(x: 0,
            y: cell.detailTextView.frame.height,
            width: textSize.width,
            height: textSize.height
        )
        cell.textView.frame = cell.bubbleView.bounds
        
        cell.mediaContainer.frame = cell.bubbleView.bounds
        
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
