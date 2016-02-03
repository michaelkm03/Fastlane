//
//  NSManagedObject+Deletable.swift
//  victorious
//
//  Created by Michael Sena on 1/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension NSManagedObject {
    
    var hasBeenDeleted: Bool {
        // If the MOC is nil, we've been deleted (as documented by Apple).
        guard self.managedObjectContext != nil else {
            return true
        }
        
        // However, sometimes the object needs to be refetched by its objectID to confirm
        do {
            let reloadedObject = try self.managedObjectContext?.existingObjectWithID( self.objectID )
            return reloadedObject == nil
        } catch {
            return true
        }
    }
}
