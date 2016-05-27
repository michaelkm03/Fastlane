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
        v_createdAt = content.createdAt ?? v_createdAt
        v_remoteID = content.id ?? v_remoteID
        v_shareURL = content.shareURL?.absoluteString ?? v_shareURL
        v_status = content.status ?? v_status
        v_text = content.text ?? v_text
        v_type = content.type.rawValue
        
        let author = content.author
        v_author = v_managedObjectContext.v_findOrCreateObject(["remoteId": author.id])
        v_author.populate(fromSourceModel: author)
        
        if let previewAssets = content.previewImages {
            let persistentAssets: [VImageAsset] = previewAssets.flatMap {
                let previewAsset: VImageAsset = self.v_managedObjectContext.v_findOrCreateObject([ "imageURL" : $0.mediaMetaData.url.absoluteString ])
                previewAsset.populate( fromSourceModel: $0 )
                previewAsset.content = self
                return previewAsset
            }
            v_contentPreviewAssets = Set(persistentAssets)
        }
        
        let persistentAssets: [VContentMediaAsset] = content.assets.flatMap { asset in
            let data: VContentMediaAsset = self.v_managedObjectContext.v_findOrCreateObject(["v_uniqueID": asset.uniqueID])
            data.populate(fromSourceModel: asset)
            data.v_content = self
            return data
        }
        
        v_contentMediaAssets = Set(persistentAssets)
    }
}
