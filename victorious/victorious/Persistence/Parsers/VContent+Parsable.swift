//
//  VContent+Parsable.swift
//  victorious
//
//  Created by Vincent Ho on 5/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension VContent: PersistenceParsable {
    
    func populate( fromSourceModel sourceModel: Content ) {
        isUGC = sourceModel.isUGC ?? isUGC
        releasedAt = sourceModel.releasedAt ?? releasedAt
        remoteID = sourceModel.id ?? remoteID
        shareURL = sourceModel.shareURL?.absoluteString ?? shareURL
        status = sourceModel.status ?? status
        title = sourceModel.title ?? title
        type = sourceModel.type ?? type
        isVIP = sourceModel.isVIP ?? isVIP
        
        if let previewAssets = sourceModel.previewImages {
            let persistentAssets: [VContentPreview] = previewAssets.flatMap {
                let previewAsset: VContentPreview = self.v_managedObjectContext.v_findOrCreateObject([ "imageURL" : $0.mediaMetaData.url.absoluteString ])
                previewAsset.populate( fromSourceModel: $0 )
                previewAsset.content = self
                return previewAsset
            }
            self.previewImages = Set<VContentPreview>(persistentAssets)
        }
        
        if let contentData = sourceModel.contentData {
            let persistentAssets: [VContentData] = contentData.flatMap {
                let data: VContentData = self.v_managedObjectContext.v_findOrCreateObject([ "uniqueID" :  $0.uniqueID])
                data.populate( fromSourceModel: $0 )
                data.content = self
                return data
            }
            self.assets = Set<VContentData>(persistentAssets)
        }
    }
}
