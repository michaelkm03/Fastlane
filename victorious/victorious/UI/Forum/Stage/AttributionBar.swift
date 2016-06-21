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

class AttributionBar: UIView {
    
    var dependencyManager: VDependencyManager?
    weak var delegate: AttributionBarDelegate?
    
    @IBOutlet private var profileButton: VDefaultProfileButton!
    @IBOutlet private var userNameLabel: UILabel! {
        didSet {
            userNameLabel.textColor = dependencyManager?.userNameLabelTextColor
            userNameLabel.font = dependencyManager?.userNameLabelFont
        }
    }
    
    private var displayingUser: UserModel!
    
    func configure(with user: UserModel) {
        displayingUser = user
        userNameLabel.text = user.name
        if let profileImageURL = user.previewImageURL(ofMinimumSize: profileButton.bounds.size) {
            profileButton?.setProfileImageURL(profileImageURL, forState: .Normal)
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
