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
        remoteSource = sourceModel.url.absoluteString ?? remoteSource
        source = sourceModel.source ?? source
    }
}
