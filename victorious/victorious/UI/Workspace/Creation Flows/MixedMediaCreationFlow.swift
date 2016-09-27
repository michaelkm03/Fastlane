//
//  MixedMediaCreationFlow.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Simplifies the updating of publish parameters for creation
/// flows that can handle either video or image.
protocol MixedMediaCreationFlow {
    
    func updatePublishParameters(_ publishParameters: VPublishParameters, workspace: VWorkspaceViewController)
}

extension MixedMediaCreationFlow {
    
    func updatePublishParameters(_ publishParameters: VPublishParameters, workspace: VWorkspaceViewController) {
        
        publishParameters.isVideo = workspace.creationFlowController.mediaType() == .Video
        if workspace.supportsTools {
            if let videoToolController = workspace.toolController as? VVideoToolController {
                publishParameters.didTrim = videoToolController.didTrim
                publishParameters.isGIF = false
            } else if let imageToolController = workspace.toolController as? VImageToolController {
                publishParameters.embeddedText = imageToolController.embeddedText
                publishParameters.textToolType = imageToolController.textToolType
                publishParameters.filterName = imageToolController.filterName
                publishParameters.didCrop = imageToolController.didCrop
            } else {
                assertionFailure("Mixed media camera creation flow controller encountered an unexpected tool controller")
            }
        }
    }
}
