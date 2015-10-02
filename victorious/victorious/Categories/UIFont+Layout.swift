//
//  UIFont+Layout.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 10/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

enum FontFamily: String {
    case Josefin = "Josefin Sans"
}

/// An extension that provides font specific values to layout text properly in a text view.
extension UIFont {
    /// Returns the line spacing to be used in the text view's paragraph style. Default is 0.
    func v_fontSpecificLineSpace() -> CGFloat {
        if self.familyName == FontFamily.Josefin.rawValue {
            return 3.0
        }
        return 0
    }
    
    /// Returns insets to be used in the text view's text container.
    func v_fontSpecificTextViewInsets() -> UIEdgeInsets {
        if self.familyName == FontFamily.Josefin.rawValue {
            return UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsetsZero
    }
}
