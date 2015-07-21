//
//  Experiment.swift
//  victorious
//
//  Created by Patrick Lynch on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

@objc class Experiment: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var enabled: NSNumber
    @NSManaged var id: NSNumber
}
