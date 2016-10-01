//
//  VDependencyManager.swift
//  victorious
//
//  Created by Jarod Long on 8/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

extension VDependencyManager {
    
    // MARK: - Initializing
    
    convenience init(dictionary: [String:AnyObject]) {
        self.init(parentManager: nil, configuration: dictionary, dictionaryOfClassesByTemplateName: nil)
    }
    
    // MARK: - Reading basic values
    
    func bool(for key: String) -> Bool? {
        return numberForKey(key)?.boolValue
    }
}
