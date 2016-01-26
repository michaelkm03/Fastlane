//
//  VPublishParameters.swift
//  victorious
//
//  Created by Patrick Lynch on 12/15/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VPublishParameters {
    var commentMediaAttachmentType: MediaAttachmentType {
        if self.isGIF {
            return .GIF
        } else if self.isVideo {
            return .Video
        }
        return .Image
    }
}