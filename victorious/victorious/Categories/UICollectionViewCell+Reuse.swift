//
//  UICollectionViewCell+Reuse.swift
//  victorious
//
//  Created by Patrick Lynch on 7/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

extension UICollectionViewCell {
    
    
    /// Returns the class name as a string, intended to match and reuse identifier's configured in interface builder
    static var suggestedReuseIdentifier: String {
        return NSStringFromClass(self).pathExtension
    }
}