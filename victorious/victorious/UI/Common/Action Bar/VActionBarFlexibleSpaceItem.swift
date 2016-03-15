//
//  VActionBarFlexibleSpaceItem.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class VActionBarFlexibleSpaceItem: UIView {
    
    class func flexibleSpaceItem() -> VActionBarFlexibleSpaceItem {
        let flexibleSpaceItem = VActionBarFlexibleSpaceItem.init(frame: CGRect.zero)
        flexibleSpaceItem.translatesAutoresizingMaskIntoConstraints = false
        return flexibleSpaceItem
    }
}
