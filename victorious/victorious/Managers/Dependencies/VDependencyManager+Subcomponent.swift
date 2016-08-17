//
//  VDependencyManager+Subcomponent.swift
//  victorious
//
//  Created by Patrick Lynch on 3/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VDependencyManager {
    /// Using the provided key, attempts to retrieve a dictionary used to intantiate
    /// a child dependency manager for a subcomponent, such as a "cell" component
    /// of a ".screen" component with a table or collection view.
    func childDependencyForKey(key: String) -> VDependencyManager? {
        guard let configuration = templateValueOfType(NSDictionary.self, forKey: key) as? [NSObject: AnyObject] else {
            return nil
        }
        
        return childDependencyManagerWithAddedConfiguration(configuration)
    }
    
    /// Returns an array of child dependency managers located at the given `key`, or nil if an array doesn't exist at
    /// that key.
    func childDependencies(for key: String) -> [VDependencyManager]? {
        guard let array = arrayForKey(key) as? [[NSObject: AnyObject]] else {
            return nil
        }
        
        return array.flatMap { childDependencyManagerWithAddedConfiguration($0) }
    }
}
