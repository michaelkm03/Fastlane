//
//  VContentMediaAsset+Parsable.swift
//  victorious
//
//  Created by Vincent Ho on 5/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension VContentMediaAsset: PersistenceParsable {
    
    func populate( fromSourceModel sourceModel: ContentMediaAsset ) {
        remoteSource = sourceModel.url?.absoluteString ?? remoteSource
        source = sourceModel.source ?? source
        externalID = sourceModel.externalID ?? externalID
        uniqueID = sourceModel.uniqueID ?? uniqueID
    }
}
