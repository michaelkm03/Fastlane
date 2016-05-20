//
//  VImageAsset.swift
//  victorious
//
//  Created by Vincent Ho on 5/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import CoreData

@objc(VImageAsset)
class VImageAsset: NSManagedObject {
    
    @NSManaged var height: NSNumber?
    @NSManaged var imageURL: String
    @NSManaged var type: String
    @NSManaged var width: NSNumber?
    @NSManaged var streamItems: NSSet?
    @NSManaged var user: VUser?
    @NSManaged var content: VContent?

}
