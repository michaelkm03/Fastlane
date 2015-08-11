//
//  VSequenceContentCellFactory.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// A cell factory for providing cells that represent single sequences within a stream.
class VSequenceContentCellFactory: VStreamContentCellFactory {
    
    /// The cell factory that will provide cells that represent single sequences
    let streamCellFactory: VSleekStreamCellFactory
    
    required init(dependencyManager: VDependencyManager) {
        streamCellFactory = VSleekStreamCellFactory(dependencyManager: dependencyManager)
        super.init(dependencyManager: dependencyManager)
    }
    
    override func defaultFactory() -> VStreamCellFactory? {
        return streamCellFactory
    }
    
}
