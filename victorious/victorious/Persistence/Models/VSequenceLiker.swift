//
//  VSequenceLiker.swift
//  victorious
//
//  Created by Patrick Lynch on 12/26/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class VSequenceLiker: NSManagedObject {
    @NSManaged var user: VUser
    @NSManaged var displayOrder: NSNumber
    @NSManaged var sequence: VSequence
    @NSManaged var sequenceId: String
}
