//
//  VImageAsset+Serialization.swift
//  victorious
//
//  Created by Patrick Lynch on 11/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VImageAsset: PersistenceParsable {
    func populate(fromSourceModel imageAsset: ImageAssetModel) {
        height = imageAsset.mediaMetaData.size.height
        width = imageAsset.mediaMetaData.size.width
        imageURL = imageAsset.mediaMetaData.url.absoluteString ?? imageURL
    }
}
