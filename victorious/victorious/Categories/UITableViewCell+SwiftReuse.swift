//
//  UITableViewCell+SwiftReuse.swift
//  victorious
//
//  Created by Patrick Lynch on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

extension UITableViewCell {
    static var defaultSwiftReuseIdentifier: String {
        return stringFromClass(self)
    }
}
