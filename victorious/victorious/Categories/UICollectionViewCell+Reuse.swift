//
//  UICollectionViewCell+Reuse.swift
//  victorious
//
//  Created by Patrick Lynch on 7/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

extension UICollectionViewCell {
    
    static var suggestedReuseIdentifier: String {
        return NSStringFromClass(self).pathExtension
    }
}