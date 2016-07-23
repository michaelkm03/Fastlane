//
//  UsernameLocationAvatarCell.swift
//  victorious
//
//  Created by Michael Sena on 7/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Provides UI for editing the user's `name`, `location`, and `tagline` fields.
/// Assign closures to be notified of events in the UI.
class UsernameLocationAvatarCell: UITableViewCell, UITextFieldDelegate {
    
    struct Constants {
        static let placeholderAlpha = CGFloat(0.5)
    }
    
    /// Provide a closure to be notified when the return key is pressed in either
    /// the username or location text fields.
    var onReturnKeySelected: (() -> ())?
    
    /// Provide a closure to be notified when the user taps on their avatar
    /// indicating that they want to
    var onAvatarSelected: (() -> ())?
    
    /// Provide a closure to be notified when any data within the cell has changed.
    var onDataChange: (() -> ())?
    
    var user: UserModel? {
        didSet {
            usernameField.text = user?.name
            locationField.text = user?.location
            avatarView.user = user
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
            guard let dependencyManager = dependencyManager,
                font = dependencyManager.placeholderAndEnteredTextFont,
                placeholderTextColor = dependencyManager.placeholderTextColor,
                enteredTextColor = dependencyManager.enteredTextColor else {
                    return
            }
            
            // Font + Colors
            usernameField.font = font
            locationField.font = font
            usernameField.textColor = enteredTextColor
            locationField.textColor = enteredTextColor
            
            // Placeholder
            let placeholderAttributes = [NSForegroundColorAttributeName: placeholderTextColor.colorWithAlphaComponent(Constants.placeholderAlpha)]
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
    @IBOutlet private weak var avatarView: AvatarView! {
        didSet {
            avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOnAvatar(_:))))
        }
    }
    
    // MARK: - API
    
    func beginEditing() {
        usernameField.becomeFirstResponder()
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
        dispatch_after(0.001, {
            if textField == self.usernameField {
                self.locationField.becomeFirstResponder()
            } else if textField == self.locationField {
                self.onReturnKeySelected?()
            }
        })
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
