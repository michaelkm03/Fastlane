//
//  UITableViewCell+VBackgroundContainer.swift
//  victorious
//
//  Created by Darvish Kamalia on 6/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension UITableViewCell : VBackgroundContainer {
    public func backgroundContainerView() -> UIView {
        return self.contentView
    }
}