//
//  MessageCollectionCellDecorator.swift
//  victorious
//
//  Created by Patrick Lynch on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol AlignmentLayout {
    func layoutSubviews(cell: VMessageCollectionCell)
}

struct MessageCollectionCellDecorator {
    
    let dependencyManager: VDependencyManager
    
    func decorateCell( cell: VMessageCollectionCell, withMessage message: VMessage) {

        if message.sender == VCurrentUser.user() {
            cell.alignmentLayout = RightAlignmentedLayout()
        } else {
            cell.alignmentLayout = LeftAlignmentedLayout()
        }
        
        cell.style = VMessageCollectionCell.Style(
            textColor: UIColor.v_colorFromHexString("b294ca"),
            backgroundColor: UIColor.v_colorFromHexString("1b1c34"),
            font: UIFont.systemFontOfSize(16.0))
        
        cell.viewData = VMessageCollectionCell.ViewData(
            text: "\(message.displayOrder): \(message.text ?? "")",
            createdAt: message.postedAt,
            username: message.sender.name ?? ""
        )
    }
}
