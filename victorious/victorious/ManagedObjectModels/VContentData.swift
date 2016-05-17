//
//  VContentData.swift
//  victorious
//
//  Created by Vincent Ho on 5/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import CoreData


class VContentData: NSManagedObject {
    
    @NSManaged var remoteSource: String? ///<Remote URL string of the content. Will be nil when externalID is not nil.
    @NSManaged var source: String?
    @NSManaged var externalID: String? ///<External ID string of the remot content. Will be nil when remoteSource is not nil.
    @NSManaged var content: VContent?
    @NSManaged var uniqueID: String? ///<Unique identifier based on either the remoteSource or externalID as exactly one of those will be nil at any time.

}
