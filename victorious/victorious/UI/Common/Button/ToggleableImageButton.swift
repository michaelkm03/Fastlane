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
    override var isSelected: Bool {
        didSet {
            delegate?.button(button: self, becameSelected: isSelected)
        }
    }
    
    weak var delegate: ToggleableImageButtonDelegate?
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager?) -> ToggleableImageButton {
        let button = ToggleableImageButton()
        button.dependencyManager = dependencyManager
        button.addTarget(button, action: #selector(toggle), for: .touchUpInside)
        return button
    }
    
    var dependencyManager: VDependencyManager? {
        didSet {
            var unselectedImage: UIImage? = templateAppearanceValue(appearance: .unselectedImage)
            if let unselectedColor: UIColor = templateAppearanceValue(appearance: .unselectedColor) {
                unselectedImage = unselectedImage?.v_tintedTemplateImage(with: unselectedColor)
            }
            
            setImage(unselectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
            
            var selectedImage: UIImage? = templateAppearanceValue(appearance: .selectedImage)
            if let selectedColor: UIColor = templateAppearanceValue(appearance: .selectedColor) {
                selectedImage = selectedImage?.v_tintedTemplateImage(with: selectedColor)
            }
            setImage(selectedImage, for: .selected)
            
            backgroundColor = .clear
        }
    }

    private dynamic func toggle() {
        isSelected = !isSelected
    }
}
