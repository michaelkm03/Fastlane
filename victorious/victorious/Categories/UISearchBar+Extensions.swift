//
//  UISearchBar+Extensions.swift
//  victorious
//
//  Created by Patrick Lynch on 7/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

extension UISearchBar {
    
    /// Finds the `UITextField` subview into which users type their search string
    var v_textField: UITextField? {
        return self.v_findSubview({ $0 is UITextField }) as? UITextField
    }
}