//
//  UserShelf.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import CoreData

class UserShelf: Shelf {

    @NSManaged var postsCount: NSNumber
    @NSManaged var followersCount: NSNumber
    @NSManaged var user: VUser

}
