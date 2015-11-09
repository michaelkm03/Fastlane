//
//  SampleCoreDataModels.swift
//  VictoriousIOSSDK
//
//  Created by Patrick Lynch on 10/16/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation
import CoreData
@testable import victorious

public extension NSManagedObject {
    public func identifier() -> AnyObject { return self.objectID }
}

public class PersistentEntity: NSManagedObject, DataStoreObject {
    
    @NSManaged public var dateAttribute: NSDate?
    @NSManaged public var numberAttribute: NSNumber?
    @NSManaged public var newStringAttribute: String?
    @NSManaged public var transientEntity: TransientEntity?
    
    public static override func entityName() -> String { return "PersistentEntity" }
    
    public func serialize( dictionary: [String : AnyObject] ) {
        self.dateAttribute = dictionary[ "dateAttribute" ] as? NSDate
        self.numberAttribute = dictionary[ "numberAttribute" ] as? NSNumber
        self.newStringAttribute = dictionary[ "newStringAttribute" ] as? String
    }
    
    public func deserialize() -> [String : AnyObject] {
        return [:]
    }
}

public class TransientEntity: NSManagedObject, DataStoreObject {
    
    @NSManaged public var stringAttribute: String?
    @NSManaged public var persistentEntity: PersistentEntity?
    
    public static override func entityName() -> String { return "TransientEntity" }
    
    public func serialize( dictionary: [String : AnyObject] ) {
        self.stringAttribute = dictionary[ "stringAttribute" ] as? String
    }
    
    public func deserialize() -> [String : AnyObject] {
        return [:]
    }
}