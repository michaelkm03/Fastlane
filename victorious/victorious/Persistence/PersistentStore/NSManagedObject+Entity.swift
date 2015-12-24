//
//  NSManagedObject+Entity.swift
//  Persistence
//
//  Created by Patrick Lynch on 10/14/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension NSManagedObject {
    
    class func v_entityName() -> String {
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
    
    var v_managedObjectContext: NSManagedObjectContext {
        guard let moc = self.managedObjectContext else {
            fatalError( "Attempt to access an `NSManagedObjectContext` instance that is `nil` on the receiver \(self.dynamicType).  This managed object has probably been deleted from the managed object context somewhere else in the application." )
        }
        return moc
    }
}

extension NSPredicate {
    
    convenience init(format: String, argumentArray: [AnyObject]?, paginator: NumericPaginator ) {
        let start = (paginator.pageNumber - 1) * paginator.itemsPerPage
        let end = start + paginator.itemsPerPage
        let connector = format.isEmpty ? "" : " && "
        let paginationFormat = connector + "displayOrder >= %@ && displayOrder < %@"
        let paginationArguments: [AnyObject] = [start, end]
        self.init(format: format + paginationFormat, argumentArray: (argumentArray ?? []) + paginationArguments)
    }
    
    convenience init(paginator: NumericPaginator ) {
        self.init(format: "", argumentArray: [], paginator: paginator)
    }
}
