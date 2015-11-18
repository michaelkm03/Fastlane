//
//  PersistentStoreContext.swift
//  Persistence
//
//  Created by Patrick Lynch on 10/14/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// An interface that defines a object object used by the PersistentStoreContext protocol.  Model types that will
/// be managed using a PersistentStoreContext object must implement PersistentStoreObject.
@objc public protocol PersistentStoreObject : class {
    
    /// Identifies the type of the object to the store for operations such as loading, saving, etc.
    static func dataStoreEntityName() -> String
    
    var identifier: AnyObject { get }
}

extension NSManagedObject: PersistentStoreObject {
    
    public class func dataStoreEntityName() -> String {
        let className = (NSStringFromClass(self) as NSString)
        if className.pathExtension.characters.count > 0 {
            return className.pathExtension
        }
        else if className.substringToIndex(1) == "V" {
            return className.substringFromIndex(1)
        }
        else {
            return className as String
        }
    }
    
    public var identifier: AnyObject {
        return self.objectID
    }
}

public protocol PersistentStoreObjectSwift: PersistentStoreObject {
    var persistentStoreContext: PersistentStoreContext { get }
}

extension NSManagedObject: PersistentStoreObjectSwift {
    
    public var persistentStoreContext: PersistentStoreContext {
        guard let persistentStoreContext = self.managedObjectContext as? PersistentStoreContext else {
            fatalError( "There is no managed object context associated with this managed object." +
                "Most likely you are trying to perform an operation on an object that has been deleted." )
        }
        return persistentStoreContext
    }
}

/// Adapts methods of the PersistentStoreContext protocol to use generics
public protocol PersistentStoreContext: PersistentStoreContextBasic {
    
    func getObject<T: PersistentStoreObjectSwift>( identifier: AnyObject ) -> T?
    
    func createObjectAndSave<T: PersistentStoreObjectSwift>( @noescape configurations: (T) -> () ) -> T
    
    func createObject<T: PersistentStoreObjectSwift>() -> T
    
    func findOrCreateObject<T: PersistentStoreObjectSwift>( queryDictionary: [ String : AnyObject ] ) -> T
    
    func findObjects<T: PersistentStoreObjectSwift>( queryDictionary: [ String : AnyObject ], limit: Int  ) -> [T]
    
    func findObjects<T: PersistentStoreObjectSwift>( queryDictionary: [ String : AnyObject ]  ) -> [T]
    
    func findObjects<T: PersistentStoreObjectSwift>( limit limit: Int ) -> [T]
    
    func findObjects<T: PersistentStoreObjectSwift>() -> [T]
}
