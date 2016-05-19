//
//  VContentPreviewAsset.swift
//  victorious
//
//  Created by Vincent Ho on 5/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import CoreData


class VContentPreviewAsset: NSManagedObject {
    
    @NSManaged var height: NSNumber?
    @NSManaged var imageURL: String?
    @NSManaged var type: String?
    @NSManaged var width: NSNumber?
    @NSManaged var content: VContent?

}
