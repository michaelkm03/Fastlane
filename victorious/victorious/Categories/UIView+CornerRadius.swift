//
//  UIView+CornerRadius.swift
//  victorious
//
//  Created by Michael Sena on 6/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension UIView {
    func applyCornerRadius(radius: CGFloat = 6.0){
        layer.cornerRadius = radius
        clipsToBounds = true
    }
}
