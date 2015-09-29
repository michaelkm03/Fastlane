//
//  NSManagedObject+Extensions.swift
//  victorious
//
//  Created by Patrick Lynch on 7/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    /// Returns the class name as a string, intended to match that which is configured in the MOM file.
    static var v_defaultEntityName: String {
        return StringFromClass(self)
    }
}