//
//  SampleCoreDataModels.swift
//  VictoriousIOSSDK
//
//  Created by Patrick Lynch on 10/16/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation
import CoreData

public extension NSManagedObject {
    public func identifier() -> AnyObject { return self.objectID }
}

public class PersistentEntity: NSManagedObject {
    
    @NSManaged public var dateAttribute: NSDate?
    @NSManaged public var numberAttribute: NSNumber?
    @NSManaged public var newStringAttribute: String?
    @NSManaged public var transientEntity: TransientEntity?
    
    public static override func entityName() -> String { return "PersistentEntity" }
}

public class TransientEntity: NSManagedObject {
    
    @NSManaged public var stringAttribute: String?
    @NSManaged public var persistentEntity: PersistentEntity?
    
    public static override func entityName() -> String { return "TransientEntity" }
}