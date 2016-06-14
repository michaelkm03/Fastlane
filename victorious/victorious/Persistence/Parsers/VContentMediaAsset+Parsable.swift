//
//  VContentMediaAsset+Parsable.swift
//  victorious
//
//  Created by Vincent Ho on 5/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension VContentMediaAsset: PersistenceParsable {
    func populate(fromSourceModel sourceModel: ContentMediaAssetModel) {
        v_remoteSource = sourceModel.url?.absoluteString ?? v_remoteSource
        v_source = sourceModel.source ?? v_source
        v_externalID = sourceModel.externalID ?? v_externalID
        v_uniqueID = sourceModel.resourceID ?? v_uniqueID
    }
}
