//
//  PersistentStoreContext.swift
//  Persistence
//
//  Created by Patrick Lynch on 10/14/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Defines a object object used by the PersistentStoreContext protocol.  Model types that will
/// be managed using a PersistentStoreContext must implement PersistentStoreObject.
@objc protocol PersistentStoreObject : class {
    
    /// Identifies the type of the object to the store for operations such as loading, saving, etc.
    static func dataStoreEntityName() -> String
    
    var identifier: AnyObject { get }
}

extension NSManagedObject: PersistentStoreObject {
    
    class func dataStoreEntityName() -> String {
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
    
    var identifier: AnyObject {
        return self.objectID
    }
}

protocol PersistentStoreObjectSwift: PersistentStoreObject {
    var persistentStoreContext: PersistentStoreContext { get }
}

extension NSManagedObject: PersistentStoreObjectSwift {
    
    var persistentStoreContext: PersistentStoreContext {
        guard let persistentStoreContext = self.managedObjectContext as? PersistentStoreContext else {
            fatalError( "There is no managed object context associated with this managed object." +
                "Most likely you are trying to perform an operation on an object that has been deleted." )
        }
        return persistentStoreContext
    }
}

struct PersistentStorePagination {
    let itemsPerPage: Int
    let pageNumber: Int
}

/// Adapts methods of the PersistentStoreContext protocol to use generics
protocol PersistentStoreContext: PersistentStoreContextBasic {
    
    func getObject<T: PersistentStoreObjectSwift>( identifier: AnyObject ) -> T?
    
    func createObjectAndSave<T: PersistentStoreObjectSwift>( @noescape configurations: (T) -> () ) -> T
    
    func createObject<T: PersistentStoreObjectSwift>() -> T
    
    func findOrCreateObject<T: PersistentStoreObjectSwift>( queryDictionary: [ String : AnyObject ] ) -> T
    
    func findObjects<T: PersistentStoreObjectSwift>( queryDictionary: [ String : AnyObject ]?, pagination: PersistentStorePagination?, limit: Int? ) -> [T]
    
    func findObjects<T: PersistentStoreObjectSwift>( queryDictionary: [ String : AnyObject ], pagination: PersistentStorePagination ) -> [T]
    
    func findObjects<T: PersistentStoreObjectSwift>( queryDictionary: [ String : AnyObject ], limit: Int ) -> [T]
    
    func findObjects<T: PersistentStoreObjectSwift>( queryDictionary: [ String : AnyObject ] ) -> [T]
    
    func findObjects<T: PersistentStoreObjectSwift>( limit limit: Int ) -> [T]
    
    func findObjects<T: PersistentStoreObjectSwift>() -> [T]
}

extension PersistentStoreContext {
    
    func findObjects<T: PersistentStoreObjectSwift>( limit limit: Int ) -> [T] {
        return findObjects( nil, pagination: nil, limit: limit)
    }
    
    func findObjects<T: PersistentStoreObjectSwift>( queryDictionary: [ String : AnyObject ], limit: Int ) -> [T] {
        return findObjects( queryDictionary, pagination: nil, limit: limit)
    }
    
    func findObjects<T: PersistentStoreObjectSwift>( queryDictionary: [ String : AnyObject ] ) -> [T] {
        return findObjects( queryDictionary, pagination: nil, limit: nil)
    }
    
    func findObjects<T: PersistentStoreObjectSwift>( queryDictionary: [ String : AnyObject ], pagination: PersistentStorePagination ) -> [T] {
        return findObjects( queryDictionary, pagination: pagination, limit: nil)
    }
    
    func findObjects<T: PersistentStoreObjectSwift>() -> [T] {
        return findObjects( nil, pagination: nil, limit: nil)
    }
}
