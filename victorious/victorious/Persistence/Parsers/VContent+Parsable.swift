//
//  VContent+Parsable.swift
//  victorious
//
//  Created by Vincent Ho on 5/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension VContent {
    func populate(fromSourceModel content: Content) {
        v_isVIPOnly = content.isVIPOnly ?? v_isVIPOnly
        v_postedAt = content.postedAt?.value ?? v_postedAt
        v_createdAt = content.createdAt.value
        v_paginationTimestamp = content.paginationTimestamp.value
        v_remoteID = content.id ?? v_remoteID
        v_shareURL = content.shareURL?.absoluteString ?? v_shareURL
        v_linkedURL = content.linkedURL?.absoluteString ?? v_linkedURL
        v_status = content.status ?? v_status
        v_text = content.text ?? v_text
        v_type = content.type.rawValue
        
        /// We do not want to update the like status after it has been populated.
        /// If a user likes a piece of content, and the outgoing request fails, we don't want the user to know anything went wrong.
        /// Same thing if they want to unlike a piece of content. Therefore, we will show the user a state that they always expect,
        /// and we will update again on the next launch when our persistent store is cleared.
        v_isRemotelyLikedByCurrentUser = v_isRemotelyLikedByCurrentUser ?? content.isRemotelyLikedByCurrentUser
        
        let author = content.author
        v_author = v_managedObjectContext.v_findOrCreateObject(["remoteId": author.id])
        v_author.populate(fromSourceModel: author)
        
        let persistentImageAssets: [VImageAsset] = content.previewImages.flatMap { imageAsset in
            let previewAsset: VImageAsset = self.v_managedObjectContext.v_createObject()
            previewAsset.populate(fromSourceModel: imageAsset)
            previewAsset.content = self
            return previewAsset
        }
        
        v_contentPreviewAssets = Set(persistentImageAssets)
        
        let persistentAssets: [VContentMediaAsset] = content.assets.flatMap { asset in
            guard let remoteID = asset.resourceID else {
                return nil
            }
            let data: VContentMediaAsset = self.v_managedObjectContext.v_findOrCreateObject(["v_remoteID": remoteID, "v_content": self])
            data.populate(fromSourceModel: asset)
            data.v_content = self
            return data
        }
        
        v_contentMediaAssets = Set(persistentAssets)
        
        if let sourceTracking = content.tracking {
            if let v_tracking = v_tracking {
                v_managedObjectContext.deleteObject(v_tracking)
            }
            
            let tracking: VTracking = v_managedObjectContext.v_createObject()
            tracking.populate(fromSourceModel: sourceTracking)
            tracking.content = self
            v_tracking = tracking
        }
    }
}
