//
//  UIColor+Hex.swift
//  victorious
//
//  Created by Jarod Long on 7/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init?(rgbHexString: String) {
        let hexNSString = rgbHexString as NSString
        
        guard hexNSString.length == 6 else {
            return nil
        }
        
        guard let red = UIColor.scanHexComponent(from: hexNSString, in: NSRange(location: 0, length: 2)) else {
            return nil
        }
        
        guard let green = UIColor.scanHexComponent(from: hexNSString, in: NSRange(location: 2, length: 2)) else {
            return nil
        }
        
        guard let blue = UIColor.scanHexComponent(from: hexNSString, in: NSRange(location: 4, length: 2)) else {
            return nil
        }
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    private static func scanHexComponent(from string: NSString, in range: NSRange) -> CGFloat? {
        let scanner = NSScanner(string: string.substringWithRange(range))
        var value = UInt32(0)
        
        guard scanner.scanHexInt(&value) else {
            return nil
        }
        
        return CGFloat(value) / 255.0
    }
    
    var rgbHexString: String {
        if self == UIColor.whiteColor() {
            return "ffffff"
        }
        
        var red = CGFloat(0.0)
        var green = CGFloat(0.0)
        var blue = CGFloat(0.0)
        var alpha = CGFloat(0.0)
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let redInt = Int(red * 255)
        let greenInt = Int(green * 255)
        let blueInt = Int(blue * 255)
        
        return String(format: "%02x%02x%02x", redInt, greenInt, blueInt)
    }
}
