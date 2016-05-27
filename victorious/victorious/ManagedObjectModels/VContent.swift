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
    
    @NSManaged var v_createdAt: NSDate
    @NSManaged var v_remoteID: String
    @NSManaged var v_shareURL: String?
    @NSManaged var v_status: String?
    @NSManaged var v_text: String?
    @NSManaged var v_type: String
    @NSManaged var v_isVIPOnly: NSNumber?
    @NSManaged var v_contentMediaAssets: Set<VContentMediaAsset>
    @NSManaged var v_author: VUser
    @NSManaged var v_contentPreviewAssets: Set<VImageAsset>

}
