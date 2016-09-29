//
//  VDependencyManager+Subcomponent.swift
//  victorious
//
//  Created by Patrick Lynch on 3/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VDependencyManager {
    /// Using the provided key, attempts to retrieve a dictionary used to instantiate
    /// a child dependency manager for a subcomponent, such as a "cell" component
    /// of a ".screen" component with a table or collection view.
    func childDependency(forKey key: String) -> VDependencyManager? {
        guard let configuration = templateValue(ofType: NSDictionary.self, forKey: key) as? [AnyHashable: Any] else {
            return nil
        }
        
        return childDependencyManager(withAddedConfiguration: configuration)
    }
    
    /// Returns an array of child dependency managers located at the given `key`, or nil if an array doesn't exist at
    /// that key.
    func childDependencies(for key: String) -> [VDependencyManager]? {
        guard let array = array(forKey: key) as? [[AnyHashable: Any]] else {
            return nil
        }
        
        return array.flatMap { childDependencyManager(withAddedConfiguration: $0) }
    }
}
