//
//  VContentPreview+Parsable.swift
//  victorious
//
//  Created by Vincent Ho on 5/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension VContentPreview: PersistenceParsable {
    
    func populate( fromSourceModel sourceModel: ImageAsset ) {
        width = sourceModel.mediaMetaData.size?.width ?? width
        height = sourceModel.mediaMetaData.size?.height ?? height
        imageURL = sourceModel.mediaMetaData.url.absoluteString ?? imageURL
        type = sourceModel.type ?? type
    }
}
