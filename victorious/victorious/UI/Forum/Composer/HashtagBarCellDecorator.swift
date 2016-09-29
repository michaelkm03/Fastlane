//
//  HashtagBarCellDecorator.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Styles a `HashtagBarCell`
struct HashtagBarCellDecorator {
    
    let font: UIFont
    let textColor: UIColor
    
    /// Returns nil iff required font or color values are not present in the provided dependencyManager
    init?(dependencyManager: VDependencyManager) {
        guard let font = dependencyManager.font,
            let textColor = dependencyManager.textColor else {
                v_log("Failed to create HashtagBarCellDecorator because of missing template values")
                return nil
        }

        self.font = font
        self.textColor = textColor
    }
    
    /// Applies text styling to a `HashtagBarCell`'s label
    func decorateCell(_ cell: HashtagBarCell) {
        
        cell.label.font = font
        cell.label.textColor = textColor
        cell.backgroundColor = .clear
    }
}

private extension VDependencyManager {
    
    var font: UIFont? {
        return font(forKey: "font.suggestedHashtag.text")
    }
    
    var textColor: UIColor? {
        return color(forKey: "color.suggestedHashtag.text")
    }
}
