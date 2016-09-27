//
//  ActionBarFlexibleSpaceItem.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

(VActionBarFlexibleSpaceItem)
class ActionBarFlexibleSpaceItem: UIView {
    
    class func flexibleSpaceItem() -> ActionBarFlexibleSpaceItem {
        let flexibleSpaceItem = ActionBarFlexibleSpaceItem.init(frame: CGRect.zero)
        flexibleSpaceItem.translatesAutoresizingMaskIntoConstraints = false
        return flexibleSpaceItem
    }
}
