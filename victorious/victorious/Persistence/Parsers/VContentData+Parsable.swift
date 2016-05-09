//
//  VContentData+Parsable.swift
//  victorious
//
//  Created by Vincent Ho on 5/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension VContentData: PersistenceParsable {
    
    func populate( fromSourceModel sourceModel: ContentDataAsset ) {
        duration = sourceModel.duration
        width = sourceModel.width
        height = sourceModel.height
        remoteSource = sourceModel.data
    }
}
