//
//  UIStoryboard+Extensions.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension UIStoryboard {
    class func storyboardFromMainBundle(name: String) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: NSBundle.mainBundle())
    }
}
