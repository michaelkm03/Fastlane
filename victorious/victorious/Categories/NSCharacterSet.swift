//
//  NSCharacterSet.swift
//  victorious
//
//  Created by Michael Sena on 9/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension NSCharacterSet {
    
    public class func validUsernameCharacterSet() -> NSCharacterSet {
        return NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyz0123456789_")
    }

}
