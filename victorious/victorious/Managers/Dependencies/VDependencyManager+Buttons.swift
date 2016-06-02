//
//  VDependencyManager+Buttons.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Public dependency manager extension for getting a button from the template.
extension VDependencyManager {
    
    func buttonForKey(key: String) -> UIButton? {
        return templateValueOfType(UIButton.self, forKey: key) as? UIButton
    }
}
