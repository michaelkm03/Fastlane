//
//  UsernameLocationAvatarCell.swift
//  victorious
//
//  Created by Michael Sena on 7/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class UsernameLocationAvatarCell: UITableViewCell, UITextFieldDelegate {
    
    /// Provide a closure to be notified when the return key is pressed in either
    /// the username or location text fields.
    var onReturnKeySelected: (() -> ())?
    
    var username: String? {
        get {
            return usernameField.text
        }
    }
    
    var location: String? {
        get {
            return locationField.text
        }
    }
    
    var dependencyManager: VDependencyManager? {
        didSet {
            // Visual Configuration
            guard let dependencyManager = dependencyManager,
                let font = dependencyManager.placeholderAndEnteredTextFont,
                let placeholderTextColor = dependencyManager.placeholderTextColor,
                let enteredTextColor = dependencyManager.enteredTextColor else {
                    return
            }
            
            // Font + Colors
            usernameField.font = font
            locationField.font = font
            usernameField.textColor = enteredTextColor
            locationField.textColor = enteredTextColor
            
            // Placeholder
            let placeholderAttributes = [NSForegroundColorAttributeName: placeholderTextColor]
            usernameField.attributedPlaceholder = NSAttributedString(string: "Name",
                                                                     attributes: placeholderAttributes)
            locationField.attributedPlaceholder = NSAttributedString(string: "Location",
                                                                     attributes: placeholderAttributes)
            
            // Background
            contentView.backgroundColor = dependencyManager.cellBackgroundColor
        }
    }
    
    @IBOutlet private var usernameField: UITextField! {
        didSet {
            usernameField.delegate = self
        }
    }
    
    @IBOutlet private var locationField: UITextField! {
        didSet {
            locationField.delegate = self
        }
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if textField == usernameField {
            locationField.becomeFirstResponder()
        } else if textField == locationField {
            onReturnKeySelected?()
        }
        return true
    }
    
}

private extension VDependencyManager {
    
    var placeholderAndEnteredTextFont: UIFont? {
        return fontForKey("font.paragraph")
    }
    
    var placeholderTextColor: UIColor? {
        return colorForKey("color.text.placeholder")
    }
    
    var enteredTextColor: UIColor? {
        return colorForKey("color.text")
    }
    
    var cellBackgroundColor: UIColor? {
        return colorForKey("color.accent")
    }
}
