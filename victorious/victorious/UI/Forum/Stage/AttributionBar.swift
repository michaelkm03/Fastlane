//
//  AttributionBar.swift
//  victorious
//
//  Created by Tian Lan on 6/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

protocol AttributionBarDelegate: class {
    func didTapOnUser(user: UserModel)
}

/// An attribution bar that displays author information of a piece of content
class AttributionBar: UIView {
    
    // MARK: - Configuration
    var dependencyManager: VDependencyManager?
    weak var delegate: AttributionBarDelegate?
    
    private var displayingUser: UserModel!
    
    func configure(with user: UserModel) {
        displayingUser = user
        userNameButton.setTitle(user.name, forState: .Normal)
        if let profileImageURL = user.previewImageURL(ofMinimumSize: profileButton.bounds.size) {
            profileButton?.setProfileImageURL(profileImageURL, forState: .Normal)
        }
    }
    
    // MARK: - Outlets and Actions
    @IBOutlet private var profileButton: VDefaultProfileButton!
    @IBOutlet private var userNameButton: UIButton! {
        didSet {
            userNameButton.setTitleColor(dependencyManager?.userNameLabelTextColor, forState: .Normal)
            userNameButton.titleLabel?.font = dependencyManager?.userNameLabelFont
        }
    }
    
    @IBAction private func didTapOnUser() {
        delegate?.didTapOnUser(displayingUser)
    }
}

private extension VDependencyManager {
    var userNameLabelFont: UIFont {
        return fontForKey("font.username") ?? UIFont.systemFontOfSize(16)
    }
    
    var userNameLabelTextColor: UIColor {
        return colorForKey("color.username") ?? UIColor.whiteColor()
    }
}
