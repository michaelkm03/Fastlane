//
//  Experiment.swift
//  victorious
//
//  Created by Patrick Lynch on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class Experiment: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var id: NSNumber
    @NSManaged var bucketType: String?
    @NSManaged var bucketCount: NSNumber?
    @NSManaged var layerId: NSNumber
    @NSManaged var layerName: String
    @NSManaged var isEnabled: NSNumber
}
