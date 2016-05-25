//
//  VContent+Parsable.swift
//  victorious
//
//  Created by Vincent Ho on 5/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension VContent: PersistenceParsable {
    
    func populate(fromSourceModel content: Content) {
        v_isVIP = content.isVIP ?? v_isVIP
        v_releasedAt = content.releasedAt ?? v_releasedAt
        v_remoteID = content.id ?? v_remoteID
        v_shareURL = content.shareURL?.absoluteString ?? v_shareURL
        v_status = content.status ?? v_status
        v_text = content.text ?? v_text
        v_type = content.type.rawValue
        
        if let author = content.author where v_author == nil {
            v_author = v_managedObjectContext.v_findOrCreateObject(["remoteId": author.id]) as VUser
            v_author?.populate(fromSourceModel: author)
        }
        
        if let previewAssets = content.previewImages {
            let persistentAssets: [VImageAsset] = previewAssets.flatMap {
                let previewAsset: VImageAsset = self.v_managedObjectContext.v_findOrCreateObject([ "imageURL" : $0.mediaMetaData.url.absoluteString ])
                previewAsset.populate( fromSourceModel: $0 )
                previewAsset.content = self
                return previewAsset
            }
            v_contentPreviewAssets = Set<VImageAsset>(persistentAssets)
        }
        
        let persistentAssets: [VContentMediaAsset] = content.contentData.flatMap {
            let data: VContentMediaAsset = self.v_managedObjectContext.v_findOrCreateObject([ "uniqueID" :  $0.uniqueID])
            data.populate( fromSourceModel: $0 )
            data.content = self
            return data
        }
        
        v_contentMediaAssets = Set<VContentMediaAsset>(persistentAssets)
    }
}
