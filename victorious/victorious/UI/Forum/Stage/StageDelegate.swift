//
//  StageDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Conformers will recieve messages related to stage media.
protocol StageDelegate: class {
    
    func stage(stage: Stage, didUpdateContentSize size: CGSize)
    
    func stage(stage: Stage, didUpdateWithMedia media: ForumMedia)
    
    func stage(stage: Stage, didSelectMedia media: ForumMedia)
}