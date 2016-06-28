//
//  CaptionBarDecorator.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

struct CaptionBarDecorator {
    
    let dependencyManager: VDependencyManager
    
    func decorate(captionBar: CaptionBar) {
        let captionLabel = captionBar.captionLabel
        captionLabel.font = dependencyManager.font
        captionLabel.textColor = dependencyManager.textColor ?? .whiteColor()
        captionLabel.backgroundColor = dependencyManager.textContainerColor
        captionBar.overlayView.backgroundColor = dependencyManager.backgroundOverlayColor
        
        let avatarImageView = captionBar.avatarImageView
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height / 2
        avatarImageView.clipsToBounds = true
        
        captionLabel.layer.cornerRadius = 6
        captionLabel.clipsToBounds = true
    }
}

private extension VDependencyManager {
    
    var font: UIFont? {
        return fontForKey("font.caption")
    }
    
    var textColor: UIColor? {
        return colorForKey("color.caption")
    }
    
    var backgroundOverlayColor: UIColor? {
        return colorForKey("color.background.caption")
    }
    
    var textContainerColor: UIColor? {
        return colorForKey("color.textContainer.caption")
    }
}
