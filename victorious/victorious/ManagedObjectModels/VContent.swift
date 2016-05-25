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
    @NSManaged var releasedAt: NSDate
    @NSManaged var remoteID: String
    @NSManaged var v_shareURL: String?
    @NSManaged var status: String?
    @NSManaged var text: String?
    @NSManaged var v_type: String /// < "image", "video", "gif", "text"
    @NSManaged var isVIP: NSNumber?
    @NSManaged var contentMediaAssets: NSSet? /// <NSSet of VContentMediaAsset objects
    @NSManaged var v_author: VUser?
    @NSManaged var contentPreviewAssets: NSSet?  /// <NSSet of VImageAsset objects

}
