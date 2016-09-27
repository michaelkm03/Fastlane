//
//  UIView+Nib.swift
//  victorious
//
//  Created by Patrick Lynch on 9/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension UIView {
    
    /// Attempts to load a typed view from a Nib
    ///
    /// :param: nibNameOrNil The name of the nib to load.  If nil is provided, the name of the
    /// generic type T will be used.
    static func v_fromNib<T: UIView>(_ nibNameOrNil: String? = nil) -> T {
        let name = nibNameOrNil ?? String(self)
        if let nibViews = Bundle.mainBundle().loadNibNamed(name, owner: nil, options: nil) {
            for view in nibViews {
                if let typedView = view as? T {
                    return typedView
                }
            }
        }
        fatalError( "Could not load view from nib named: \(name)" )
    }
}
