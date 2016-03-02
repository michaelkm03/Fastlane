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
            textColor: dependencyManager.textColor,
            backgroundColor: dependencyManager.backgroundColor,
            font: dependencyManager.titleFont
        )
        
        cell.viewData = VMessageCollectionCell.ViewData(
            text: "\(message.text ?? "")",
            createdAt: message.postedAt,
            username: message.sender.name ?? ""
        )
    }
}

private extension VDependencyManager {
    
    var textColor: UIColor {
        return self.colorForKey(VDependencyManagerSecondaryTextColorKey)
    }
    
    var backgroundColor: UIColor {
        return self.colorForKey(VDependencyManagerSecondaryAccentColorKey)
    }
    
    var titleFont: UIFont {
        return self.fontForKey(VDependencyManagerLabel1FontKey)
    }
}
