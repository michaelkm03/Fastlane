//
//  VContentMediaAsset.swift
//  victorious
//
//  Created by Vincent Ho on 5/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import CoreData

class VContentMediaAsset: NSManagedObject {
    
    @NSManaged var externalID: String?
    @NSManaged var remoteSource: String?
    @NSManaged var source: String?
    @NSManaged var uniqueID: String?
    @NSManaged var content: VContent?
    
}
