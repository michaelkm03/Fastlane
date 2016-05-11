//
//  VContent.swift
//  victorious
//
//  Created by Vincent Ho on 5/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import CoreData

class VContent: NSManagedObject {
    
    @NSManaged var isUGC: NSNumber?
    @NSManaged var releasedAt: NSDate?
    @NSManaged var remoteID: String?
    @NSManaged var shareURL: String?
    @NSManaged var status: String?
    @NSManaged var title: String?
    @NSManaged var type: String? /// < "image", "video", "gif"
    @NSManaged var assets: NSSet?
    @NSManaged var previewImages: NSSet?
    @NSManaged var viewedContent: VViewedContent?

}
