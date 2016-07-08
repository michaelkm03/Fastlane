//
//  VDependencyManager+APIPath.swift
//  victorious
//
//  Created by Jarod Long on 6/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK

extension VDependencyManager {
    func apiPathForKey(key: String) -> APIPath? {
        guard let string = stringForKey(key) else {
            return nil
        }
        
        return APIPath(templatePath: string)
    }
}
