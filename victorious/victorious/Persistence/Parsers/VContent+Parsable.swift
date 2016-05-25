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
        isVIP = content.isVIP ?? isVIP
        isUGC = content.isUGC ?? isUGC
        releasedAt = content.releasedAt ?? releasedAt
        remoteID = content.id ?? remoteID
        shareURL = content.shareURL?.absoluteString ?? shareURL
        status = content.status ?? status
        text = content.text ?? text
        type = content.type.rawValue
        
        if let author = content.author where self.author == nil {
            self.author = v_managedObjectContext.v_findOrCreateObject(["remoteId": author.id]) as VUser
            self.author?.populate(fromSourceModel: author)
        }
        
        if let previewAssets = content.previewImages {
            let persistentAssets: [VImageAsset] = previewAssets.flatMap {
                let previewAsset: VImageAsset = self.v_managedObjectContext.v_findOrCreateObject([ "imageURL" : $0.mediaMetaData.url.absoluteString ])
                previewAsset.populate( fromSourceModel: $0 )
                previewAsset.content = self
                return previewAsset
            }
            self.contentPreviewAssets = Set<VImageAsset>(persistentAssets)
        }
        
        let persistentAssets: [VContentMediaAsset] = content.contentData.flatMap {
            let data: VContentMediaAsset = self.v_managedObjectContext.v_findOrCreateObject([ "uniqueID" :  $0.uniqueID])
            data.populate( fromSourceModel: $0 )
            data.content = self
            return data
        }
        
        self.contentMediaAssets = Set<VContentMediaAsset>(persistentAssets)
    }
}
