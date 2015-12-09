//
//  Experiment+Parsable.swift
//  victorious
//
//  Created by Michael Sena on 12/8/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension Experiment: PersistenceParsable {
    
    func populate(fromSourceModel sourceModel: DeviceExperiment) {   
        name = sourceModel.name
        id = NSNumber(longLong: sourceModel.id)
        bucketType = sourceModel.bucketType
        bucketCount = NSNumber(longLong: sourceModel.numberOfBuckets)
        layerId = NSNumber(longLong: sourceModel.layerID)
        layerName = sourceModel.layerName
    }
    
}

