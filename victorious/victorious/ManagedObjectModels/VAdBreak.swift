//
//  VAdBreak.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@objc class VAdBreak: NSManagedObject {
    @NSManaged var adSystemID: NSNumber
    @NSManaged var timeout: NSNumber
    @NSManaged var adTag: String?
}
