//
//  StatusBarUtils.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 10/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class StatusBarUtilities: NSObject {
    // Returns an appropriate status bar style based on the illuminance of a color
    class func statusBarStyle(color: UIColor) -> UIStatusBarStyle {
        
        let luminance = color.v_colorLuminance()
        switch luminance {
        case .Bright:
            return .LightContent
        case .Dark:
            return .Default
        }
    }
}
