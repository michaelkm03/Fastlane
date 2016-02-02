//
//  VStreamChild.swift
//  victorious
//
//  Created by Patrick Lynch on 2/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import CoreData

class VStreamChild: NSManagedObject {
    @NSManaged var streamItem: VStreamItem
    @NSManaged var stream: VStream
    @NSManaged var displayOrder: NSNumber!
}
