//
//  HashtagBarCellDecorator.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

struct HashtagBarCellDecorator {
    
    private let font: UIFont
    
    private let deselectedTextColor: UIColor
    
    private let selectedTextColor: UIColor
    
    private let selectedBackgroundColor: UIColor
    
    init?(dependencyManager: VDependencyManager) {
        guard let font = dependencyManager.font,
            let deselectedTextColor = dependencyManager.deselectedTextColor,
            let selectedTextColor = dependencyManager.selectedTextColor,
            let selectedBackgroundColor = dependencyManager.selectedBackgroundColor else {
                v_log("Failed to create HashtagBarCellDecorator because of missing template values")
                return nil
        }

        self.font = font
        self.deselectedTextColor = deselectedTextColor
        self.selectedTextColor = selectedTextColor
        self.selectedBackgroundColor = selectedBackgroundColor
    }
    
    func decorateCell(cell: HashtagBarCell, selected: Bool) {
        
        cell.label.font = font
        cell.label.textColor = selected ? selectedTextColor : deselectedTextColor
        cell.label.backgroundColor = selected ? selectedBackgroundColor : .clearColor()
    }
}

private extension VDependencyManager {
    
    var font: UIFont? {
        return fontForKey("font.suggestedHashtag")
    }
    
    var deselectedTextColor: UIColor? {
        return colorForKey("color.suggestedHashtag.text.deselected")
    }
    
    var selectedTextColor: UIColor? {
        return colorForKey("color.suggestedHashtag.text.selected")
    }
    
    var selectedBackgroundColor: UIColor? {
        return colorForKey("color.suggestedHashtag.background.selected")
    }
}
