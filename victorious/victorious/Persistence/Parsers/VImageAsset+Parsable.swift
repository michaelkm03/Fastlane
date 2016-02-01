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
    
    func populate( fromSourceModel imageAsset: ImageAsset ) {
        height = imageAsset.size.height ?? height
        imageURL = imageAsset.url.absoluteString ?? imageURL
        type = imageAsset.type ?? type
        width = imageAsset.size.width ?? width
    }
}
