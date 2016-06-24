//
//  CtAErrorState.swift
//  victorious
//
//  Created by Darvish Kamalia on 6/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

private struct Constants {
    static let messageTextKey = "message"
    static let messageFontKey = "message.font"
    static let messageColorKey = "message.color"
    static let actionButtonKey = "action.button"
}

class CtAErrorState: UIView {
    private let messageLabel = UILabel()
    private var actionButton: UIButton?
    private var stackView = UIStackView()
    private let dependencyManager: VDependencyManager

    init(frame: CGRect, dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        messageLabel.text = dependencyManager.stringForKey(Constants.messageTextKey)
        messageLabel.font = dependencyManager.fontForKey(Constants.messageFontKey)
        messageLabel.textColor = dependencyManager.colorForKey(Constants.messageColorKey)
        if let button = dependencyManager.buttonForKey(Constants.actionButtonKey) {
            actionButton = button
            stackView.addArrangedSubview(button)
        }
        stackView.axis = .Vertical
        stackView.alignment = .Center
        stackView.addArrangedSubview(messageLabel)
        self.addSubview(stackView)
        v_addFitToParentConstraintsToSubview(stackView)
    }


}
