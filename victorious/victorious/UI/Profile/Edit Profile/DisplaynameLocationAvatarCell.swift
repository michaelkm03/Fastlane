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
    
    private struct Constants {
        static let placeholderAlpha = CGFloat(0.5)
    }
    
    @IBOutlet private var displaynameField: UITextField! {
        didSet {
            NSNotificationCenter.defaultCenter().addObserver(self,
                                                             selector: #selector(textFieldDidChange(_:)),
                                                             name: UITextFieldTextDidChangeNotification,
                                                             object: displaynameField)
        }
    }
    
    @IBOutlet private var usernameField: UITextField! {
        didSet {
            NSNotificationCenter.defaultCenter().addObserver(self,
                                                             selector: #selector(textFieldDidChange(_:)),
                                                             name: UITextFieldTextDidChangeNotification,
                                                             object: usernameField)
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
    
    @IBOutlet private var avatarView: AvatarView! {
        didSet {
            avatarView.size = .large
            avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOnAvatar(_:))))
        }
    }
    
    // MARK: - API
    
    /// Provide a closure to be notified when the return key is pressed in either
    /// the displayname or location text fields.
    var onReturnKeySelected: (() -> Void)?
    
    /// Provide a closure to be notified when the user taps on their avatar
    /// indicating that they want to
    var onAvatarSelected: (() -> Void)?
    
    /// Provide a closure to be notified when any data within the cell has changed.
    var onDataChange: (() -> Void)?
    
    var displayname: String? {
        get {
            return displaynameField.text
        }
        set {
            displaynameField.text = newValue
        }
    }
    
    var username: String? {
        get {
            return usernameField.text
        }
        set {
            usernameField.text = newValue
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
            usernameField.font = font
            locationField.font = font
            displaynameField.textColor = enteredTextColor
            usernameField.textColor = enteredTextColor
            locationField.textColor = enteredTextColor
            
            // Placeholder
            let placeholderAttributes = [NSForegroundColorAttributeName: placeholderTextColor.colorWithAlphaComponent(Constants.placeholderAlpha)]
            displaynameField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("DisplayNamePlaceholder", comment: "Placeholder text for the user's name as it is displayed to others."),
                                                                     attributes: placeholderAttributes)
            usernameField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("UserNamePlaceholder", comment: "Placeholder text for the user's username that is globally unique as it is displayed to others."),
                                                                        attributes: placeholderAttributes)
            locationField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("LocationPlaceholder", comment: "Placeholder text for the user's location as it is displayed to others."),
                                                                     attributes: placeholderAttributes)
            
            // Background
            contentView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        }
    }
    
    func beginEditing() {
        displaynameField.becomeFirstResponder()
    }
    
    // MARK: - Target / Action
    
    @objc private func tappedOnAvatar(gesture: UITapGestureRecognizer) {
        switch gesture.state {
            case .Ended:
                self.onAvatarSelected?()
            case .Possible, .Cancelled, .Failed, .Changed, .Began:
                break
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    @objc func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == displaynameField {
            usernameField.becomeFirstResponder()
            return false
        } else if textField == usernameField {
            locationField.becomeFirstResponder()
        } else if textField == locationField {
            onReturnKeySelected?()
            return false
        }
        return true
    }

    // MARK: - Notification Handlers
    
    @objc private func textFieldDidChange(notification: NSNotification) {
        onDataChange?()
    }
}

extension DisplaynameLocationAvatarCell {
    
    func populate(withUser user: UserModel) {
        displayname = user.displayName
        username = user.username
        location = user.location
        avatarView.user = user
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
}
