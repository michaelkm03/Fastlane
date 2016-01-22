//
//  NSManagedObject+Entity.swift
//  Persistence
//
//  Created by Patrick Lynch on 10/14/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

public extension NSManagedObject {
    
    class func v_entityName() -> String {
        var className = (NSStringFromClass(self) as NSString)
        if className.pathExtension.characters.count > 0 {
            className = className.pathExtension
        }
        
        if className.substringToIndex(1) == "V" {
            return className.substringFromIndex(1)
        }
        else {
            return className as String
        }
    }
    
    var v_managedObjectContext: NSManagedObjectContext {
        guard let moc = self.managedObjectContext else {
            fatalError( "Attempt to access an `NSManagedObjectContext` instance that is `nil` on the receiver \(self.dynamicType).  This managed object has probably been deleted from the managed object context somewhere else in the application." )
        }
        return moc
    }
}
