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

extension UIFont {
    func appropriateLineSpacing() -> CGFloat {
        if self.familyName == FontFamily.Josefin.rawValue {
            return 3.0
        }
        return 0
    }
    
    func appropriateTextViewInsets() -> UIEdgeInsets {
        if self.familyName == FontFamily.Josefin.rawValue {
            return UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsetsZero
    }
}
