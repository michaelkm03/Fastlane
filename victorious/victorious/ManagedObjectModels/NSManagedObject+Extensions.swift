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
    
    // Swift class names include the module ("MyModule.MyClass"), which we'll remove using `pathExtension`
    static var defaultEntityName: String {
        return NSStringFromClass(self).pathExtension
    }
}