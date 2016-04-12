//
//  MediaAttachmentVideoView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

// A media attachment view used for showing video preview images
class MediaAttachmentVideoView: MediaAttachmentImageView {
    
    let playIcon = UIImageView(image: UIImage(named: "PlayIcon"))
    
    override func sharedInit() {
        super.sharedInit()
        
        self.addSubview(self.playIcon)
        self.v_addCenterToParentContraintsToSubview(self.playIcon)
    }
}
