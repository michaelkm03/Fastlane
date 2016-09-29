//
//  ToggleableImageButton.swift
//  victorious
//
//  Created by Vincent Ho on 9/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ToggleableImageButtonDelegate: class {
    func button(button: ToggleableImageButton, becameSelected selected: Bool)
}

/// A template-styled button that displays a toggleable image button
@objc(VToggleableImageButton)
class ToggleableImageButton: TouchableInsetAdjustableButton, TrackableButton {
    override var selected: Bool {
        didSet {
            delegate?.button(self, becameSelected: selected)
        }
    }
    
    weak var delegate: ToggleableImageButtonDelegate?
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager?) -> ToggleableImageButton {
        let button = ToggleableImageButton()
        button.dependencyManager = dependencyManager
        button.addTarget(button, action: #selector(toggle), forControlEvents: .TouchUpInside)
        return button
    }
    
    var dependencyManager: VDependencyManager? {
        didSet {
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
            
            backgroundColor = .clear
        }
    }

    private dynamic func toggle() {
        selected = !selected
    }
}
