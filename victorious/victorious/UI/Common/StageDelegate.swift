//
//  StageDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol StageDelegate: class {
    
    /// Called when the media on the stage changes.
    func stage(stage: Stage, updatedToMedia media: StageMedia)
    
    /// Called when the user taps on a piece of media on the stage.
    func stage(stage: Stage, selectedMedia media: StageMedia)
}