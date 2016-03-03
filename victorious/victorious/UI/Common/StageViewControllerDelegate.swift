//
//  StageViewControllerDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol StageViewControllerDelegate: class {
    
    /// Called when the media on the stage changes
    func stage(stage: StageViewController, updatedToMedia media: VAsset, withSize size: CGSize)
    
    /// Called when the user taps on a piece of media on the stage
    func stage(stage: StageViewController, selectedMedia media: VAsset)
}