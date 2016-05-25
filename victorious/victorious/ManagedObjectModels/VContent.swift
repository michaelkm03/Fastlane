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
    
    @NSManaged var v_releasedAt: NSDate
    @NSManaged var v_remoteID: String
    @NSManaged var v_shareURL: String?
    @NSManaged var v_status: String?
    @NSManaged var v_text: String?
    @NSManaged var v_type: String /// < "image", "video", "gif", "text"
    @NSManaged var v_isVIP: NSNumber?
    @NSManaged var v_contentMediaAssets: NSSet? /// <NSSet of VContentMediaAsset objects
    @NSManaged var v_author: VUser
    @NSManaged var v_contentPreviewAssets: NSSet?  /// <NSSet of VImageAsset objects

}
