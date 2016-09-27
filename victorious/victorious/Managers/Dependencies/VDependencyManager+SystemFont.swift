//
//  VDependencyManager+SystemFont.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VDependencyManager {
    
    fileprivate func weightOfSystemFontWithName(_ name: String) -> CGFloat? {
        
        let normalizedName = name.lowercased
        guard normalizedName.hasPrefix("systemfont-") else {
            return nil
        }
        
        switch normalizedName {
            case "systemfont-ultralight":
                return UIFontWeightUltraLight
            case "systemfont-thin":
                return UIFontWeightThin
            case "systemfont-light":
                return UIFontWeightLight
            case "systemfont-regular":
                return UIFontWeightRegular
            case "systemfont-medium":
                return UIFontWeightMedium
            case "systemfont-semibold":
                return UIFontWeightSemibold
            case "systemfont-bold":
                return UIFontWeightBold
            case "systemfont-heavy":
                return UIFontWeightHeavy
            case "systemfont-black":
                return UIFontWeightBlack
            default:
                return UIFontWeightRegular
        }
    }
    
    /// Returns a system font when appropriate
    func fontWithName(_ name: String, size: CGFloat) -> UIFont? {
        if let weight = weightOfSystemFontWithName(name) {
            return UIFont.systemFontOfSize(size, weight: weight)
        }
        return UIFont(name: name, size: size)
    }
}
