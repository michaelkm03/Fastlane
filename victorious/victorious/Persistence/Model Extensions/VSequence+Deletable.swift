//
//  VSequence+Deletable.swift
//  victorious
//
//  Created by Michael Sena on 1/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VSequence: Deletable {
    
    var markedForDeletion: Bool {
        get {
            return self.markForDeletion.boolValue
        }
        set {
            self.markForDeletion = newValue
        }
    }
    
    static var markedForDeletionPredicate: NSPredicate {
        return NSPredicate(format: "%K == YES", VSequence.Keys.markForDeletion.rawValue)
    }
    
    static var notMarkedForDeletionPredicate: NSPredicate{
        return NSPredicate(format: "%K == NO", VSequence.Keys.markForDeletion.rawValue)
    }
}
