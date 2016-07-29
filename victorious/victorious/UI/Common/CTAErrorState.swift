//
//  CTAErrorState.swift
//  victorious
//
//  Created by Darvish Kamalia on 6/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

enum CTAErrorStateActionType {
    case openSettings
}

private struct Constants {
    static let messageTextKey = "message"
    static let messageFontKey = "message.font"
    static let messageColorKey = "message.color"
    static let actionButtonKey = "action.button"
    static let minimumSpacing: CGFloat = 10
    static let buttonCornerRadius: CGFloat = 5
}

/// A reusable error state class that tells the user that the current screen is not usable unless
/// they perform a specific action.
class CTAErrorState: UIView {
    private let messageLabel = UILabel()
    private var actionButton = TextOnColorButton()
    private let dependencyManager: VDependencyManager
    private let actionType: CTAErrorStateActionType

    init(frame: CGRect, dependencyManager: VDependencyManager, actionType: CTAErrorStateActionType) {
        self.dependencyManager = dependencyManager
        self.actionType = actionType
        super.init(frame: frame)
        setupViews()
        actionButton.addTarget(self, action: #selector(CTAErrorState.performButtonAction), forControlEvents: .TouchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        messageLabel.text = dependencyManager.messageLabelText
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .Center
        messageLabel.font = dependencyManager.messageLabelFont
        messageLabel.textColor = dependencyManager.messageLabelColor
        
        actionButton.dependencyManager = dependencyManager.childDependencyForKey(Constants.actionButtonKey)
        actionButton.roundingType = .roundedRect(radius: Constants.buttonCornerRadius)
        
        addSubview(messageLabel)
        
        messageLabel.widthAnchor.constraintEqualToAnchor(self.widthAnchor).active = true
        messageLabel.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        messageLabel.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(actionButton)
        actionButton.widthAnchor.constraintEqualToAnchor(self.widthAnchor).active = true
        actionButton.topAnchor.constraintEqualToAnchor(messageLabel.bottomAnchor, constant: Constants.minimumSpacing).active = true
        actionButton.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
        actionButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc private func performButtonAction() {
        actionButton.dependencyManager?.trackButtonEvent(.tap)
        switch actionType {
            case .openSettings:
                if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
        }
    }
}

private extension VDependencyManager {
    var messageLabelText: String {
        return stringForKey(Constants.messageTextKey)
    }
    
    var messageLabelFont: UIFont? {
        return fontForKey(Constants.messageFontKey)
    }
    
    var messageLabelColor: UIColor? {
        return colorForKey(Constants.messageColorKey)
    }
}