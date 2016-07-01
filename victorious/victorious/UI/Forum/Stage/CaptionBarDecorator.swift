//
//  CaptionBarDecorator.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

struct CaptionBarDecorator {
    private struct Constants {
        static let textAreaCornerRadius: CGFloat = 6
        static let expandButtonTouchInsets = UIEdgeInsetsMake(-6, -6, -6, -6)
    }
    
    let dependencyManager: VDependencyManager
    
    func decorate(captionBar: CaptionBar) {
        let captionTextView = captionBar.captionTextView
        captionTextView.font = dependencyManager.font
        captionTextView.textColor = dependencyManager.textColor ?? .whiteColor()
        captionTextView.backgroundColor = dependencyManager.textContainerColor
        
        let captionLabel = captionBar.captionLabel
        captionLabel.font = dependencyManager.font
        captionLabel.textColor = dependencyManager.textColor ?? .whiteColor()
        captionLabel.backgroundColor = dependencyManager.textContainerColor
        captionLabel.numberOfLines = captionBar.collapsedNumberOfLines
        
        captionBar.overlayView.backgroundColor = dependencyManager.backgroundOverlayColor
        
        captionTextView.layer.cornerRadius = Constants.textAreaCornerRadius
        captionTextView.clipsToBounds = true
        
        captionLabel.layer.cornerRadius = Constants.textAreaCornerRadius
        captionLabel.clipsToBounds = true
        
        captionBar.expandButton.touchInsets = Constants.expandButtonTouchInsets
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
