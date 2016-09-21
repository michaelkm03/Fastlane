//
//  CustomInputDisplayOptions.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

// Encapsulates the height and view controller of an input area
struct CustomInputDisplayOptions {
    let viewController: UIViewController
    let desiredHeight: CGFloat
}

func ==(lhs: CustomInputDisplayOptions?, rhs: CustomInputDisplayOptions?) -> Bool {
    return lhs?.viewController == rhs?.viewController && lhs?.desiredHeight == rhs?.desiredHeight
}
