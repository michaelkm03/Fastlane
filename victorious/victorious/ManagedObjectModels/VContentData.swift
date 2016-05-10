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
    
    @NSManaged var remoteSource: String?
    @NSManaged var source: String?
    @NSManaged var content: VContent?

}
