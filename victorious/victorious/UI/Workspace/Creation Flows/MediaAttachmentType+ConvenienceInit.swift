//
//  MediaAttachmentType+ConvenienceInit.swift
//  victorious
//
//  Created by Sharif Ahmed on 4/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension MediaAttachmentType {
    
    init?(creationFlowController: VCreationFlowController) {
        switch creationFlowController.mediaType() {
        case .Image:
            self = .Image
        case .Video:
            if creationFlowController.dynamicType == VGIFCreationFlowController.self {
                self = .GIF
            } else {
                self = .Video
            }
        default:
            assertionFailure("Creation flow controller returned an invalid media type.")
            return nil
        }
    }
}
