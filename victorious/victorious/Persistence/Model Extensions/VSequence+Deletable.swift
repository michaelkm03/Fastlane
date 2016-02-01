//
//  VSequence+Deletable.swift
//  victorious
//
//  Created by Michael Sena on 1/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/*extension VSequence: Deletable {
    
    var markedForDeletion: Bool {
        get {
            return self.markedForDeletion.boolValue
        }
        set {
            self.markedForDeletion = newValue
        }
    }
    
    static var markedForDeletionPredicate: NSPredicate {
        return NSPredicate(format: "%K == YES", VSequence.Keys.markedForDeletion.rawValue)
    }
    
    static var notMarkedForDeletionPredicate: NSPredicate{
        return NSPredicate(format: "%K == NO", VSequence.Keys.markedForDeletion.rawValue)
    }
}
*/


extension NSManagedObject {
    
    var hasBeenDeleted: Bool {
        // If the MOC is nil, we've been deleted (as documented by Apple).
        guard let managedObjectContext = managedObjectContext else {
            return true
        }
        
        // However, sometimes the object needs to be refetched by its objectID (which is very fast)
        // And the `managedObjectContext` property checked for that object.
        return managedObjectContext.objectWithID( self.objectID ).managedObjectContext == nil
    }
}
