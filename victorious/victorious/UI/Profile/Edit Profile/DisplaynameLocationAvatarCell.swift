//
//  DisplaynameLocationAvatarCell.swift
//  victorious
//
//  Created by Michael Sena on 7/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Provides UI for editing the user's `name`, `location`, and `tagline` fields.
/// Assign closures to be notified of events in the UI.
class DisplaynameLocationAvatarCell: UITableViewCell, UITextFieldDelegate {
    
    struct Constants {
        static let placeholderAlpha = CGFloat(0.5)
    }
    
    /// Provide a closure to be notified when the return key is pressed in either
    /// the displayname or location text fields.
    var onReturnKeySelected: (() -> Void)?
    
    /// Provide a closure to be notified when the user taps on their avatar
    /// indicating that they want to
    var onAvatarSelected: (() -> Void)?
    
    /// Provide a closure to be notified when any data within the cell has changed.
    var onDataChange: (() -> Void)?
    
    var user: UserModel? {
        didSet {
            displaynameField.text = user?.displayName
            locationField.text = user?.location
            avatarView.user = user
        }
    }
    
    var displayname: String? {
        get {
            return displaynameField.text
        }
        set {
            displaynameField.text = newValue
        }
    }
    
    var location: String? {
        get {
            return locationField.text
        }
        set {
            locationField.text = newValue
        }
    }
    
    var dependencyManager: VDependencyManager? {
        didSet {
            // Visual Configuration
            guard
                let dependencyManager = dependencyManager,
                let font = dependencyManager.placeholderAndEnteredTextFont,
                let placeholderTextColor = dependencyManager.placeholderTextColor,
                let enteredTextColor = dependencyManager.enteredTextColor else {
                    return
            }
            
            // Font + Colors
            displaynameField.font = font
            locationField.font = font
            displaynameField.textColor = enteredTextColor
            locationField.textColor = enteredTextColor
            
            // Placeholder
            let placeholderAttributes = [NSForegroundColorAttributeName: placeholderTextColor.colorWithAlphaComponent(Constants.placeholderAlpha)]
            displaynameField.attributedPlaceholder = NSAttributedString(string: "Name",
                                                                     attributes: placeholderAttributes)
            locationField.attributedPlaceholder = NSAttributedString(string: "Location",
                                                                     attributes: placeholderAttributes)
            
            // Background
            contentView.backgroundColor = dependencyManager.cellBackgroundColor
        }
    }
    
    @IBOutlet private var displaynameField: UITextField! {
        didSet {
            NSNotificationCenter.defaultCenter().addObserver(self,
                                                             selector: #selector(textFieldDidChange(_:)),
                                                             name: UITextFieldTextDidChangeNotification,
                                                             object: displaynameField)
        }
    }
    @IBOutlet private var locationField: UITextField! {
        didSet {
            NSNotificationCenter.defaultCenter().addObserver(self,
                                                             selector: #selector(textFieldDidChange(_:)),
                                                             name: UITextFieldTextDidChangeNotification,
                                                             object: locationField)
        }
    }
    @IBOutlet private weak var avatarView: AvatarView! {
        didSet {
            avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOnAvatar(_:))))
        }
    }
    
    // MARK: - API
    
    func beginEditing() {
        displaynameField.becomeFirstResponder()
    }
    
    // MARK: - Target / Action
    
    @objc func tappedOnAvatar(gesture: UITapGestureRecognizer) {
        switch gesture.state {
            case .Ended:
                self.onAvatarSelected?()
            case .Possible, .Cancelled, .Failed, .Changed, .Began:
                break
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == displaynameField {
            locationField.becomeFirstResponder()
            return false
        } else if textField == locationField {
            onReturnKeySelected?()
            return false
        }
        return true
    }

    // MARK: - Notification Handlers
    
    func textFieldDidChange(notification: NSNotification) {
        onDataChange?()
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
