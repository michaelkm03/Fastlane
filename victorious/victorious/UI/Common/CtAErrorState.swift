//
//  CtAErrorState.swift
//  victorious
//
//  Created by Darvish Kamalia on 6/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

enum CtAErrorStateActionType {
    case openSettings
}

private struct Constants {
    static let messageTextKey = "message"
    static let messageFontKey = "message.font"
    static let messageColorKey = "message.color"
    static let actionButtonKey = "action.button"
}

/// A reusable error state class that tells the user that the current screen is not usable unless
/// they perform a specific action.
class CtAErrorState: UIView {
    private let messageLabel = UILabel()
    private var actionButton: UIButton?
    private var stackView = UIStackView()
    private let dependencyManager: VDependencyManager
    private let actionType: CtAErrorStateActionType

    init(frame: CGRect, dependencyManager: VDependencyManager, actionType: CtAErrorStateActionType) {
        self.dependencyManager = dependencyManager
        self.actionType = actionType
        super.init(frame: frame)
        setupViews()
        actionButton?.addTarget(self, action: #selector(CtAErrorState.performButtonAction), forControlEvents: .TouchUpInside)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        messageLabel.text = dependencyManager.stringForKey(Constants.messageTextKey)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .Center
        messageLabel.font = dependencyManager.fontForKey(Constants.messageFontKey)
        messageLabel.textColor = dependencyManager.colorForKey(Constants.messageColorKey)
        stackView.addArrangedSubview(messageLabel)
        if let button = dependencyManager.buttonForKey(Constants.actionButtonKey) {
            actionButton = button
            stackView.addArrangedSubview(button)
        }
        stackView.axis = .Vertical
        stackView.alignment = .Fill
        stackView.distribution = .EqualSpacing
        self.addSubview(stackView)
        v_addFitToParentConstraintsToSubview(stackView)
    }
    
    @objc private func performButtonAction() {
        switch actionType {
            case .openSettings:
                if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
    }
}
