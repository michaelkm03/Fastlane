//
//  StageController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol StageController {
    
    weak var delegate: StageControllerDelegate? { get set }
    
    /// Replaces the currently playing media with the one provided.
    func startPlayingMedia(media: VAsset)
    
    /// Stops displaying the currently shown media.
    func stopPlayingContent()
}
