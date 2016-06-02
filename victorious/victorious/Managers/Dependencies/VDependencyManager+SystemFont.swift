//
//  VDependencyManager+SystemFont.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VDependencyManager {
    
    private func weightOfSystemFontWithName(name: String) -> CGFloat? {
        
        let normalizedName = name.lowercaseString
        guard normalizedName.hasPrefix("systemfont-") else {
            return nil
        }
        
        switch normalizedName {
        case "systemfont-light":
            return UIFontWeightLight
        case "systemfont-regular":
            return UIFontWeightRegular
        case "systemfont-medium":
            return UIFontWeightMedium
        case "systemfont-bold":
            return UIFontWeightBold
        default:
            return UIFontWeightRegular
        }
    }
    
    /// Returns a system font when appropriate
    func fontWithName(name: String, size: CGFloat) -> UIFont? {
        if let weight = weightOfSystemFontWithName(name) {
            return UIFont.systemFontOfSize(size, weight: weight)
        }
        return UIFont(name: name, size: size)
    }
}
