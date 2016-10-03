//
//  VDependencyManager.swift
//  victorious
//
//  Created by Jarod Long on 8/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

extension VDependencyManager {
    convenience init(dictionary: [String: Any]) {
        self.init(parentManager: nil, configuration: dictionary, dictionaryOfClassesByTemplateName: nil)
    }
}
