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
    
    @NSManaged var v_externalID: String? ///<External ID string of the remot content. Will be nil when remoteSource is not nil.
    @NSManaged var v_remoteSource: String? ///<Remote URL string of the content. Will be nil when externalID is not nil.
    @NSManaged var v_source: String?
    @NSManaged var v_uniqueID: String ///<Unique identifier based on either the remoteSource or externalID as exactly one of those will be nil at any time.
    
    @NSManaged var v_content: VContent

}
