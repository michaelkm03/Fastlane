//
//  UIView+ReuseIdentifier.swift
//  victorious
//
//  Created by Patrick Lynch on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

extension UIView {

    /// Returns `self`'s class name as a default reuse identifer
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}
