//
//  HashtagBarCellDecorator.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

struct HashtagBarCellDecorator {
    
    let font: UIFont
    let textColor: UIColor
    
    init?(dependencyManager: VDependencyManager) {
        guard let font = dependencyManager.font,
            let textColor = dependencyManager.textColor else {
                v_log("Failed to create HashtagBarCellDecorator because of missing template values")
                return nil
        }

        self.font = font
        self.textColor = textColor
    }
    
    func decorateCell(cell: HashtagBarCell) {
        
        cell.label.font = font
        cell.label.textColor = textColor
        cell.backgroundColor = .clearColor()
    }
}

private extension VDependencyManager {
    
    var font: UIFont? {
        return fontForKey("font.suggestedHashtag.text")
    }
    
    var textColor: UIColor? {
        return colorForKey("color.suggestedHashtag.text")
    }
}
