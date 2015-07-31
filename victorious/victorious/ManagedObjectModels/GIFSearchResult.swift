//
//  GIFSearchResult.swift
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import CoreData

@objc class GIFSearchResult: NSManagedObject {
    @NSManaged var gifUrl: String
    @NSManaged var gifSize: NSNumber
    @NSManaged var mp4Url: String
    @NSManaged var mp4Size: NSNumber
    @NSManaged var frames: NSNumber
    @NSManaged var width: NSNumber
    @NSManaged var height: NSNumber
    @NSManaged var thumbnailUrl: String
    @NSManaged var thumbnailStillUrl: String
}