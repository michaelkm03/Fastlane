//
//  NotificationCell.swift
//  victorious
//
//  Created by Jarod Long on 4/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// The table view cell used to display notifications.
class NotificationCell: UITableViewCell, VBackgroundContainer {
    // MARK: - Constants
    
    private static let containerCornerRadius: CGFloat = 6.0
    private static let shadowRadius: CGFloat = 1.25
    private static let shadowOpacity: Float = 0.4
    
    // MARK: - Initializing
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = NotificationCell.containerCornerRadius
        selectionStyle = .None
        
        profileShadowView.layer.shadowColor = UIColor.blackColor().CGColor
        profileShadowView.layer.shadowRadius = NotificationCell.shadowRadius
        profileShadowView.layer.shadowOpacity = NotificationCell.shadowOpacity
        profileShadowView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        
        backgroundColor = nil
        backgroundView?.backgroundColor = nil
    }
    
    // MARK: - Content
    
    func updateContent(with notification: VNotification, dependencyManager: VDependencyManager) {
        profileButton.user = notification.user
        profileButton.dependencyManager = dependencyManager
        profileButton.tintColor = dependencyManager.profileButtonTintColor
        
        dateLabel.text = notification.createdAt.stringDescribingTimeIntervalSinceNow(format: .verbose, precision: .minutes) ?? ""
        
        dateLabel.font = dependencyManager.dateFont
        
        let message = notification.subject
        
        dependencyManager.addBackgroundToBackgroundHost(self, forKey: VDependencyManagerCellBackgroundKey)
        
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
        
        let username = notification.user.name ?? ""
        let range = (message as NSString).rangeOfString(username)
        
        if range.location != NSNotFound && range.length > 0 {
            attributedMessage.addAttributes([
                NSFontAttributeName: boldFont
            ], range: range)
        }
        
        messageLabel.attributedText = attributedMessage
    }
    
    // MARK: - Delegate
    
    weak var delegate: VCellWithProfileDelegate?
    
    // MARK: - Views
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var profileButton: VDefaultProfileButton!
    @IBOutlet private var profileShadowView: UIView!
    @IBOutlet private var messageLabel: IntrinsicContentSizeHackLabel!
    @IBOutlet private var dateLabel: UILabel!
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateProfilePictureShadowPathIfNeeded()
    }
    
    // MARK: - Shadows
    
    private var shadowBounds: CGRect?
    
    private func updateProfilePictureShadowPathIfNeeded() {
        let newShadowBounds = profileShadowView.bounds
        
        if newShadowBounds != shadowBounds {
            shadowBounds = newShadowBounds
            profileShadowView.layer.shadowPath = UIBezierPath(ovalInRect: newShadowBounds).CGPath
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func profileButtonWasPressed() {
        delegate?.cellDidSelectProfile(self)
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return containerView
    }
}

private extension VDependencyManager {
    var profileButtonTintColor: UIColor? {
        return colorForKey(VDependencyManagerLinkColorKey)
    }
    
    var messageTextColor: UIColor? {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
    
    var dateTextColor: UIColor? {
        return colorForKey(VDependencyManagerSecondaryTextColorKey)
    }
    
    var messageFont: UIFont? {
        return fontForKey(VDependencyManagerLabel1FontKey)
    }
    
    var boldMessageFont: UIFont? {
        guard let fontDescriptor = messageFont?.fontDescriptor().fontDescriptorWithSymbolicTraits(.TraitBold) else {
            return nil
        }
        
        return UIFont(descriptor: fontDescriptor, size: 0.0)
    }
    
    var dateFont: UIFont? {
        return fontForKey(VDependencyManagerLabel2FontKey)
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
    override func intrinsicContentSize() -> CGSize {
        var size = super.intrinsicContentSize()
        size.height += 0.5
        return size
    }
}
