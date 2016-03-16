//
//  ActionBarFlexibleSpaceItem.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

@objc(VActionBarFlexibleSpaceItem)
class ActionBarFlexibleSpaceItem: UIView {
    
    /// A flexible space item for use in layout of VActionBar's action items.
    class func flexibleSpaceItem() -> ActionBarFlexibleSpaceItem {
        let flexibleSpaceItem = ActionBarFlexibleSpaceItem.init(frame: CGRect.zero)
        flexibleSpaceItem.translatesAutoresizingMaskIntoConstraints = false
        return flexibleSpaceItem
    }
}
