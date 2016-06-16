//
//  UIEdgeInsets+Addition.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension UIEdgeInsets {
    var horizontal: CGFloat {
        return left + right
    }
    
    var vertical: CGFloat {
        return top + bottom
    }
}

func +(base: UIEdgeInsets, additor: UIEdgeInsets) -> UIEdgeInsets {
    var sum = UIEdgeInsetsZero
    sum.left = base.left + additor.left
    sum.right = base.right + additor.right
    sum.top = base.top + additor.top
    sum.bottom = base.bottom + additor.bottom
    return sum
}
