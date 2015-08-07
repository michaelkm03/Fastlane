//
//  VSequenceContentCellFactory.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class VSequenceContentCellFactory : VStreamContentCellFactory {
    
    required init(dependencyManager: VDependencyManager) {
        super.init(dependencyManager: dependencyManager)
        defaultFactory = VSleekStreamCellFactory(dependencyManager: dependencyManager)
    }
    
}
