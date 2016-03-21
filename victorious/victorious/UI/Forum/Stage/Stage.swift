//
//  Stage.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol Stage: class, ForumEventReceiver {
    
    weak var delegate: StageDelegate? { get set }
    
    var dependencyManager: VDependencyManager! { get set }
    
    /// Replaces the currently playing media with the one provided.
    func startPlayingMedia(media: Stageable)
    
    /// Stops displaying the currently shown media.
    func stopPlayingMedia()
}

/// Conformers will recieve messages related to stage media.
protocol StageDelegate: class {
    
    func stage(stage: Stage, didUpdateContentHeight height: CGFloat)
    
    func stage(stage: Stage, didUpdateWithMedia media: Stageable)
    
    func stage(stage: Stage, didSelectMedia media: Stageable)
}
