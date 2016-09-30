//
//  DisplaynameLocationAvatarCell.swift
//  victorious
//
//  Created by Michael Sena on 7/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Provides UI for editing the user's `name`, `location`, and `tagline` fields.
/// Assign closures to be notified of events in the UI.
class DisplaynameLocationAvatarCell: UITableViewCell, UITextFieldDelegate {
    fileprivate struct Constants {
        static let placeholderAlpha = CGFloat(0.5)
    }
    
    @IBOutlet fileprivate var displaynameField: UITextField! {
        didSet {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(textFieldDidChange(_:)),
                name: NSNotification.Name.UITextFieldTextDidChange,
                object: displaynameField)
        }
    }
    
    @IBOutlet fileprivate var usernameField: UITextField! {
        didSet {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(textFieldDidChange(_:)),
                name: UITextFieldTextDidChangeNotification,
                object: usernameField)
        }
    }
    
    @IBOutlet fileprivate var locationField: UITextField! {
        didSet {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(textFieldDidChange(_:)),
                name: NSNotification.Name.UITextFieldTextDidChange,
                object: locationField)
        }
    }
    
    @IBOutlet fileprivate var avatarView: AvatarView! {
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
            let placeholderAttributes = [NSForegroundColorAttributeName: placeholderTextColor.withAlphaComponent(Constants.placeholderAlpha)]
            displaynameField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("DisplayNamePlaceholder", comment: "Placeholder text for the user's name as it is displayed to others."),
                                                                     attributes: placeholderAttributes)
            usernameField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("UserNamePlaceholder", comment: "Placeholder text for the user's username that is globally unique as it is displayed to others."),
                                                                        attributes: placeholderAttributes)
            locationField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("LocationPlaceholder", comment: "Placeholder text for the user's location as it is displayed to others."),
                                                                     attributes: placeholderAttributes)
            
            // Background
            contentView.backgroundColor = dependencyManager.cellBackgroundColor
        }
    }
    
    func beginEditing() {
        displaynameField.becomeFirstResponder()
    }
    
    // MARK: - Target / Action
    
    @objc fileprivate func tappedOnAvatar(_ gesture: UITapGestureRecognizer) {
        switch gesture.state {
            case .ended:
                self.onAvatarSelected?()
            case .possible, .cancelled, .failed, .changed, .began:
                break
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    
    @objc fileprivate func textFieldDidChange(_ notification: Notification) {
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
        return font(forKey: "font.paragraph")
    }
    
    var placeholderTextColor: UIColor? {
        return color(forKey: "color.text.placeholder")
    }
    
    var enteredTextColor: UIColor? {
        return color(forKey: "color.text")
    }
    
    var cellBackgroundColor: UIColor? {
        return color(forKey: "color.accent")
    }
}
