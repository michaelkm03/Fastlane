//
//  ListShelf.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import CoreData
import VictoriousIOSSDK

class ListShelf: Shelf {

    @NSManaged var caption: String
    
    override func populate(fromSourceShelf sourceShelf: StreamItemType) {
        guard let listShelf = sourceShelf as? VictoriousIOSSDK.ListShelf else { return }
        
        super.populate(fromSourceShelf: listShelf.shelf)
        
        self.caption = listShelf.caption
    }
}
