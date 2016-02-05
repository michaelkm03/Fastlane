//
//  VStreamItemPointer.swift
//  victorious
//
//  Created by Patrick Lynch on 2/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import CoreData

func ==(lhs: VStreamItemPointer, rhs: VStreamItemPointer) -> Bool {
    return lhs.streamItem == rhs.streamItem
        && lhs.marqueeParent == rhs.marqueeParent
        && lhs.streamParent == rhs.streamParent
}

class VStreamItemPointer: NSManagedObject {
    
    @NSManaged var headline: String?
    @NSManaged var streamItem: VStreamItem
    @NSManaged var streamParent: VStream?
    @NSManaged var marqueeParent: VStream?
    @NSManaged var displayOrder: NSNumber!
    @NSManaged var tracking: VTracking?
}
