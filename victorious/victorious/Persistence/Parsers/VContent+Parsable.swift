//
//  VContent+Parsable.swift
//  victorious
//
//  Created by Vincent Ho on 5/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension VContent: PersistenceParsable {
    
    func populate( fromSourceModel viewedContent: ViewedContent ) {
        
        let content = viewedContent.content
        let author = viewedContent.author
        
        isUGC = content.isUGC ?? isUGC
        releasedAt = content.releasedAt ?? releasedAt
        remoteID = content.id ?? remoteID
        shareURL = content.shareURL?.absoluteString ?? shareURL
        status = content.status ?? status
        title = content.title ?? title
        text = content.text ?? text
        type = content.type ?? type
        
        if self.author == nil {
            self.author = v_managedObjectContext.v_findOrCreateObject( [ "remoteId" : author.userID ] ) as VUser
        }
        self.author?.populate(fromSourceModel: author)
        
        if let previewAssets = content.previewImages {
            let persistentAssets: [VImageAsset] = previewAssets.flatMap {
                let previewAsset: VImageAsset = self.v_managedObjectContext.v_findOrCreateObject([ "imageURL" : $0.mediaMetaData.url.absoluteString ])
                previewAsset.populate( fromSourceModel: $0 )
                previewAsset.content = self
                return previewAsset
            }
            self.contentPreviewAssets = Set<VImageAsset>(persistentAssets)
        }
        
        if let contentData = content.contentData {
            let persistentAssets: [VContentMediaAsset] = contentData.flatMap {
                let data: VContentMediaAsset = self.v_managedObjectContext.v_findOrCreateObject([ "uniqueID" :  $0.uniqueID])
                data.populate( fromSourceModel: $0 )
                data.content = self
                return data
            }
            self.contentMediaAssets = Set<VContentMediaAsset>(persistentAssets)
        }
    }
}
