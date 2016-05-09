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
    
    @NSManaged var duration: NSNumber?
    @NSManaged var width: NSNumber?
    @NSManaged var height: NSNumber?
    @NSManaged var remoteSource: String?
    @NSManaged var content: VContent?

}
