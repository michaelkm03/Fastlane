//
//  StageControllerDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol StageControllerDelegate: class {
    
    ///This method will be called when the media on the stage changes
    func stage(stage: StageController, updatedToMedia media: VAsset, withSize size: CGSize)
    
    ///This method will be called when the user taps on a piece of media on the stage
    func stage(stage: StageController, selectedMedia media: VAsset)
}