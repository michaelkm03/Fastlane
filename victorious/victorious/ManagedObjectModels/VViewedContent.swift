//
//  VViewedContent.swift
//  victorious
//
//  Created by Vincent Ho on 5/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import CoreData


class VViewedContent: NSManagedObject {
    
    @NSManaged var author: VUser?
    @NSManaged var content: VContent?

}
