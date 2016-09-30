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
    
    func button(forKey key: String) -> UIButton? {
        return templateValue(ofType: UIButton.self, forKey: key) as? UIButton
    }
}
