//
//  ToggleableImageButton.swift
//  victorious
//
//  Created by Vincent Ho on 9/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ToggleableImageButtonDelegate: class {
    func didToggle(to selected: Bool)
}

/// A template-styled button that displays a toggleable image button
@objc(VToggleableImageButton)
class ToggleableImageButton: TouchableInsetAdjustableButton, TrackableButton {
    weak var delegate: ToggleableImageButtonDelegate?
    
    var dependencyManager: VDependencyManager? {
        didSet {
            if dependencyManager != oldValue {
                // Remove old action handler
                removeTarget(self, action: #selector(toggle), forControlEvents: .TouchUpInside)
                
                // Add a new action handler
                addTarget(self, action: #selector(toggle), forControlEvents: .TouchUpInside)
            }
            
            var unselectedImage: UIImage? = templateAppearanceValue(.unselectedImage)
            if let unselectedColor: UIColor = templateAppearanceValue(.unselectedColor) {
                unselectedImage = unselectedImage?.v_tintedTemplateImageWithColor(unselectedColor)
            }
            
            setImage(unselectedImage?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
            
            var selectedImage: UIImage? = templateAppearanceValue(.selectedImage)
            if let selectedColor: UIColor = templateAppearanceValue(.selectedColor) {
                selectedImage = selectedImage?.v_tintedTemplateImageWithColor(selectedColor)
            }
            setImage(selectedImage, forState: .Selected)
            
            backgroundColor = .clearColor()
        }
    }
    
    private dynamic func toggle() {
        selected = !selected
    }
}
