//
//  UserShelf.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import CoreData
import VictoriousIOSSDK

class UserShelf: Shelf {

    @NSManaged var postsCount: NSNumber
    @NSManaged var followersCount: NSNumber
    @NSManaged var user: VUser
    
    override func populate(fromSourceShelf sourceShelf: StreamItemType) {
        guard let userShelf = sourceShelf as? VictoriousIOSSDK.UserShelf else { return }
        
        super.populate(fromSourceShelf: userShelf.shelf)
        self.postsCount = NSNumber(integer: userShelf.shelf.postCount ?? 0)
        self.user = v_managedObjectContext.v_findOrCreateObject( [ "remoteId" : userShelf.user.id ] ) as VUser
        self.user.populate(fromSourceModel: userShelf.user)
    }
}
