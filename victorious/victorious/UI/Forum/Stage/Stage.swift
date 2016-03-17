//
//  Stage.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol Stage: class {
    
    weak var delegate: StageDelegate? { get set }
    
    var dependencyManager: VDependencyManager! { get set }
    
    var contentHeight: CGFloat { get }
    
    /// Replaces the currently playing media with the one provided.
    func startPlayingMedia(media: VAsset)
    
    /// Stops displaying the currently shown media.
    func stopPlayingContent()
}
