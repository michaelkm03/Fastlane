//
//  Experiment+Parsable.swift
//  victorious
//
//  Created by Michael Sena on 12/8/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension Experiment {
    func populate(fromSourceModel sourceModel: DeviceExperiment) {   
        name        = sourceModel.name
        id          = sourceModel.id
        bucketType  = sourceModel.bucketType
        bucketCount = sourceModel.numberOfBuckets
        layerId     = sourceModel.layerID
        layerName   = sourceModel.layerName
    }
}
