//
//  UIControl+NavigationBarEmbedding.swift
//  victorious
//
//  Created by Sharif Ahmed on 4/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Exposes a method to help size controls that will be
/// added as a custom view in a UINavigationBarButtonItem
extension UIControl {
    
    var v_navigationBarFriendlyFrame: CGRect {
       return CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50))
    }
}
