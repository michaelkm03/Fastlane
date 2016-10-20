//
//  InAppNotificationCell.swift
//  victorious
//
//  Created by Jarod Long on 4/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

/// A delegate protocol for `InAppNotificationCell`.
protocol InAppNotificationCellDelegate: class {
    func notificationCellDidSelectUser(_ notificationCell: InAppNotificationCell)
}

/// The table view cell used to display in-app notifications.
class InAppNotificationCell: UITableViewCell, VBackgroundContainer {
    private struct Constants {
        static let containerCornerRadius = CGFloat(6.0)
    }
    
    // MARK: - Initializing
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = Constants.containerCornerRadius
        selectionStyle = .none
        
        backgroundColor = nil
        backgroundView?.backgroundColor = nil
    }
    
    // MARK: - Content
    
    func updateContent(with notification: InAppNotification, dependencyManager: VDependencyManager) {
        avatarView.user = notification.user
        dateLabel.text = notification.createdAt.stringDescribingTimeIntervalSinceNow(format: .verbose, precision: .minutes)
        dateLabel.font = dependencyManager.dateFont
        
        let message = notification.subject
        
        dependencyManager.addBackground(toBackgroundHost: self, forKey: VDependencyManagerCellBackgroundKey)
        
        dateLabel.textColor = dependencyManager.dateTextColor
        
        guard
            let textColor = dependencyManager.messageTextColor,
            let font = dependencyManager.messageFont,
            let boldFont = dependencyManager.boldMessageFont
        else {
            messageLabel.text = message
            return
        }
        
        let attributedMessage = NSMutableAttributedString(string: message, attributes: [
            NSForegroundColorAttributeName: textColor,
            NSFontAttributeName: font
        ])
        
        let username = notification.user.displayName ?? ""
        let range = (message as NSString).range(of: username)
        
        if range.location != NSNotFound && range.length > 0 {
            attributedMessage.addAttributes([
                NSFontAttributeName: boldFont
            ], range: range)
        }
        
        messageLabel.attributedText = attributedMessage
    }
    
    // MARK: - Delegate
    
    weak var delegate: InAppNotificationCellDelegate?
    
    // MARK: - Views
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var avatarView: AvatarView! {
        didSet {
            avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileButtonWasPressed)))
        }
    }
    @IBOutlet private var messageLabel: IntrinsicContentSizeHackLabel!
    @IBOutlet private var dateLabel: UILabel!
    
    // MARK: - Actions
    
    @objc private func profileButtonWasPressed() {
        delegate?.notificationCellDidSelectUser(self)
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return containerView
    }
}

private extension VDependencyManager {
    var messageTextColor: UIColor? {
        return color(forKey: VDependencyManagerMainTextColorKey)
    }
    
    var dateTextColor: UIColor? {
        return color(forKey: VDependencyManagerSecondaryTextColorKey)
    }
    
    var messageFont: UIFont? {
        return font(forKey: VDependencyManagerLabel1FontKey)
    }
    
    var boldMessageFont: UIFont? {
        guard let fontDescriptor = messageFont?.fontDescriptor.withSymbolicTraits(.traitBold) else {
            return nil
        }
        
        return UIFont(descriptor: fontDescriptor, size: 0.0)
    }
    
    var dateFont: UIFont? {
        return font(forKey: VDependencyManagerLabel2FontKey)
    }
}

/// This class is used for the notification cell's message label to work around an apparent UIKit bug.
///
/// The message label is sized using autolayout according to its intrinsic content size to accommodate text wrapping.
/// For some reason, the first time a cell is displayed, the intrinsic content size reports a value 0.5 points less
/// than what it should be, which causes the last line of text to be clipped. If the cell is scrolled off screen and
/// then scrolled back, the label is laid out again with the correct intrinsic content size, and the wrapped text
/// displays correctly.
///
/// We simply bump the intrinsic height by 0.5 points so that the cell displays correctly the first time around. The
/// increase is small enough that it makes no significant visual difference after the size corrects itself.
///
/// A cleaner workaround would be welcomed if we can find one.
///
class IntrinsicContentSizeHackLabel: UILabel {
    override var intrinsicContentSize : CGSize {
        var size = super.intrinsicContentSize
        size.height += 0.5
        return size
    }
}
