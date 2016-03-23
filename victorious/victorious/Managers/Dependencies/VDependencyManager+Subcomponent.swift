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
    
        if let configuration = templateValueOfType(NSDictionary.self, forKey: key) as? [NSObject: AnyObject] {
            return self.childDependencyManagerWithAddedConfiguration(configuration)
        }
        return nil
    }
}
